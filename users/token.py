from django.contrib.auth.tokens import PasswordResetTokenGenerator as DjangoPasswordResetTokenGenerator

class EmailVerificationTokenGenerator(DjangoPasswordResetTokenGenerator):
    def _make_hash_value(self, user, timestamp):
        user_id = str(user.pk)
        ts = str(timestamp)
        is_active = str(user.is_active)
        return f"{user_id}{ts}{is_active}"
    
class PasswordRecoveryTokenGenerator(DjangoPasswordResetTokenGenerator):
    def _make_hash_value(self, user, timestamp):
        user_id = str(user.pk)
        ts = str(timestamp)
        password = str(user.password)
        return f"{user_id}{password}{ts}"
    
account_activation_token = EmailVerificationTokenGenerator()

password_reset_token = PasswordRecoveryTokenGenerator()
