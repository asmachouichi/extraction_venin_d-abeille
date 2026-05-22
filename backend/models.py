from flask_bcrypt import Bcrypt

bcrypt = Bcrypt()

class User:

    @staticmethod
    def hash_password(password):
        return bcrypt.generate_password_hash(password).decode('utf-8')

    @staticmethod
    def check_password(hash_pw, password):
        return bcrypt.check_password_hash(hash_pw, password)