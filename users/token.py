from django.contrib.auth.tokens import PasswordResetTokenGenerator

class EmailVerificationTokenGenerator(PasswordResetTokenGenerator):
    def _make_hash_value(self, user, timestamp):
        user_id = str(user.pk)
        ts = str(timestamp)
        is_active = str(user.is_active)
        return f"{user_id}{ts}{is_active}"
    
class PasswordResetTokenGenerator(PasswordResetTokenGenerator):
    def _make_hash_value(self, user, timestamp):
        user_id = str(user.pk)
        ts = str(timestamp)
        return f"{user_id}{ts}"
    
account_activation_token = EmailVerificationTokenGenerator()

password_reset_token = PasswordResetTokenGenerator()