from unittest.mock import patch

from django.contrib.auth.models import User
from django.test import TestCase

from users.models import PaymentMethod, Profile
from users.views import PaymentMethodListView


class PaymentMethodViewTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='tester',
            email='tester@example.com',
            password='secure-pass-123',
        )
        self.view = PaymentMethodListView()

    @patch('users.views.stripe.Customer.modify')
    @patch('users.views.stripe.PaymentMethod.retrieve')
    @patch('users.views.stripe.PaymentMethod.attach')
    @patch('users.views.stripe.Customer.create')
    def test_save_payment_method_creates_customer_and_sets_default(
        self,
        customer_create_mock,
        payment_method_attach_mock,
        payment_method_retrieve_mock,
        customer_modify_mock,
    ):
        customer_create_mock.return_value = {'id': 'cus_test_123'}
        payment_method_retrieve_mock.side_effect = [
            {
                'id': 'pm_test_123',
                'customer': None,
                'card': {'last4': '4242', 'brand': 'visa', 'exp_month': 12, 'exp_year': 2030},
                'billing_details': {'name': 'Tester QA'},
            },
            {
                'id': 'pm_test_123',
                'customer': 'cus_test_123',
                'card': {'last4': '4242', 'brand': 'visa', 'exp_month': 12, 'exp_year': 2030},
                'billing_details': {'name': 'Tester QA'},
            },
        ]

        self.view.save_payment_method(self.user, 'pm_test_123')

        profile = Profile.objects.get(user=self.user)
        self.assertEqual(profile.stripe_customer_id, 'cus_test_123')
        method = PaymentMethod.objects.get(user=self.user)
        self.assertEqual(method.last4, '4242')
        self.assertTrue(method.is_default)
        payment_method_attach_mock.assert_called_once_with('pm_test_123', customer='cus_test_123')
        customer_modify_mock.assert_called_once()

    @patch('users.views.stripe.Customer.modify')
    @patch('users.views.stripe.PaymentMethod.retrieve')
    @patch('users.views.stripe.Customer.retrieve')
    def test_save_payment_method_raises_when_method_belongs_to_other_customer(
        self,
        customer_retrieve_mock,
        payment_method_retrieve_mock,
        customer_modify_mock,
    ):
        Profile.objects.create(user=self.user, stripe_customer_id='cus_local_1')
        customer_retrieve_mock.return_value = {'id': 'cus_local_1'}
        payment_method_retrieve_mock.return_value = {
            'id': 'pm_other_customer',
            'customer': 'cus_other_customer',
            'card': {'last4': '0005', 'brand': 'visa', 'exp_month': 1, 'exp_year': 2030},
            'billing_details': {'name': 'Otro'},
        }

        with self.assertRaises(ValueError):
            self.view.save_payment_method(self.user, 'pm_other_customer')

        self.assertFalse(PaymentMethod.objects.filter(user=self.user).exists())
        customer_modify_mock.assert_not_called()


class PaymentMethodDeleteFlowTests(TestCase):
    def setUp(self):
        self.user = User.objects.create_user(
            username='tester_delete',
            email='delete@example.com',
            password='secure-pass-123',
        )
        self.profile = Profile.objects.create(user=self.user, stripe_customer_id='cus_delete_123')
        self.default_method = PaymentMethod.objects.create(
            user=self.user,
            stripe_payment_method_id='pm_default',
            last4='4242',
            card_brand='visa',
            expiration_month=1,
            expiration_year=2030,
            cardholder_name='Default Card',
            is_default=True,
        )
        self.secondary_method = PaymentMethod.objects.create(
            user=self.user,
            stripe_payment_method_id='pm_secondary',
            last4='4444',
            card_brand='mastercard',
            expiration_month=2,
            expiration_year=2031,
            cardholder_name='Secondary Card',
            is_default=False,
        )

    @patch('users.views.stripe.Customer.modify')
    @patch('users.views.stripe.PaymentMethod.detach')
    def test_delete_default_promotes_next_method(self, payment_method_detach_mock, customer_modify_mock):
        self.client.login(username='tester_delete', password='secure-pass-123')
        response = self.client.post(f'/users/settings/metodos-de-pago/{self.default_method.id}/eliminar/')

        self.assertEqual(response.status_code, 302)
        self.assertFalse(PaymentMethod.objects.filter(id=self.default_method.id).exists())
        self.secondary_method.refresh_from_db()
        self.assertTrue(self.secondary_method.is_default)
        payment_method_detach_mock.assert_called_once_with('pm_default')
        customer_modify_mock.assert_called_once_with(
            'cus_delete_123',
            invoice_settings={'default_payment_method': 'pm_secondary'},
        )

    @patch('users.views.stripe.Customer.modify')
    @patch('users.views.stripe.PaymentMethod.detach')
    def test_delete_fails_when_stripe_detach_fails(self, payment_method_detach_mock, customer_modify_mock):
        from stripe import APIError

        payment_method_detach_mock.side_effect = APIError('detach fail')
        self.client.login(username='tester_delete', password='secure-pass-123')
        response = self.client.post(f'/users/settings/metodos-de-pago/{self.default_method.id}/eliminar/')

        self.assertEqual(response.status_code, 302)
        self.assertTrue(PaymentMethod.objects.filter(id=self.default_method.id).exists())
        customer_modify_mock.assert_not_called()
