from flask import Flask, render_template, request, redirect, url_for, session, flash, jsonify
from flask_sqlalchemy import SQLAlchemy
from flask_login import LoginManager, UserMixin, login_user, login_required, logout_user, current_user
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import datetime, timedelta
import os

app = Flask(__name__)
app.config['SECRET_KEY'] = 'nethunt-secret-key-2024'
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///nethunt.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False

db = SQLAlchemy(app)
login_manager = LoginManager()
login_manager.init_app(app)
login_manager.login_view = 'signin'

class User(UserMixin, db.Model):
    id = db.Column(db.Integer, primary_key=True)
    email = db.Column(db.String(100), unique=True, nullable=False)
    password = db.Column(db.String(200), nullable=False)
    created_at = db.Column(db.DateTime, default=datetime.utcnow)
    trial_used = db.Column(db.Boolean, default=True)
    trial_expires = db.Column(db.DateTime, default=datetime.utcnow() + timedelta(days=1))
    is_premium = db.Column(db.Boolean, default=False)
    premium_expires = db.Column(db.DateTime, nullable=True)

    def is_trial_active(self):
        return self.trial_expires > datetime.utcnow() and not self.is_premium
    
    def is_premium_active(self):
        if self.is_premium and self.premium_expires:
            return self.premium_expires > datetime.utcnow()
        return False
    
    def has_access(self):
        return self.is_trial_active() or self.is_premium_active()

@login_manager.user_loader
def load_user(user_id):
    return User.query.get(int(user_id))

@app.route('/')
def index():
    if current_user.is_authenticated:
        return redirect(url_for('dashboard'))
    return redirect(url_for('signin'))

@app.route('/signup', methods=['GET', 'POST'])
def signup():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        if not email or not password:
            flash('Email and password are required', 'error')
            return redirect(url_for('signup'))
        
        if not email.endswith('@gmail.com'):
            flash('Only Gmail addresses are allowed', 'error')
            return redirect(url_for('signup'))
        
        if User.query.filter_by(email=email).first():
            flash('Email already exists', 'error')
            return redirect(url_for('signup'))
        
        user = User(
            email=email,
            password=generate_password_hash(password),
            trial_expires=datetime.utcnow() + timedelta(days=1)
        )
        db.session.add(user)
        db.session.commit()
        
        flash('Account created successfully! Please sign in.', 'success')
        return redirect(url_for('signin'))
    
    return render_template('signup.html')

@app.route('/signin', methods=['GET', 'POST'])
def signin():
    if request.method == 'POST':
        email = request.form.get('email')
        password = request.form.get('password')
        
        user = User.query.filter_by(email=email).first()
        if user and check_password_hash(user.password, password):
            login_user(user)
            return redirect(url_for('dashboard'))
        else:
            flash('Invalid email or password', 'error')
    
    return render_template('signin.html')

@app.route('/dashboard')
@login_required
def dashboard():
    if not current_user.has_access():
        return redirect(url_for('payment_required'))
    
    trial_status = current_user.is_trial_active()
    premium_status = current_user.is_premium_active()
    
    return render_template('dashboard.html', 
                         trial_status=trial_status,
                         premium_status=premium_status)

@app.route('/payment-required')
@login_required
def payment_required():
    return render_template('payment.html')

@app.route('/upgrade')
@login_required
def upgrade():
    return redirect('https://flutterwave.com/pay/7k8wh62jmtzh')

@app.route('/payment-success')
@login_required
def payment_success():
    current_user.is_premium = True
    current_user.premium_expires = datetime.utcnow() + timedelta(days=30)
    db.session.commit()
    flash('Premium access activated! Enjoy 30 days of unlimited access.', 'success')
    return redirect(url_for('dashboard'))

@app.route('/logout')
@login_required
def logout():
    logout_user()
    return redirect(url_for('signin'))

@app.route('/admin/login', methods=['GET', 'POST'])
def admin_login():
    if request.method == 'POST':
        username = request.form.get('username')
        password = request.form.get('password')
        
        if username == 'nethunter' and password == 'cbtpratice@nethunter':
            session['admin_logged_in'] = True
            return redirect(url_for('admin_dashboard'))
        else:
            flash('Invalid admin credentials', 'error')
    
    return render_template('admin_login.html')

@app.route('/admin')
def admin_dashboard():
    if not session.get('admin_logged_in'):
        return redirect(url_for('admin_login'))
    
    users = User.query.all()
    return render_template('admin_dashboard.html', users=users)

@app.route('/admin/grant-premium/<int:user_id>')
def grant_premium(user_id):
    if not session.get('admin_logged_in'):
        return redirect(url_for('admin_login'))
    
    user = User.query.get_or_404(user_id)
    user.is_premium = True
    user.premium_expires = datetime.utcnow() + timedelta(days=30)
    db.session.commit()
    flash(f'Premium granted to {user.email}', 'success')
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/revoke-premium/<int:user_id>')
def revoke_premium(user_id):
    if not session.get('admin_logged_in'):
        return redirect(url_for('admin_login'))
    
    user = User.query.get_or_404(user_id)
    user.is_premium = False
    user.premium_expires = None
    db.session.commit()
    flash(f'Premium revoked from {user.email}', 'success')
    return redirect(url_for('admin_dashboard'))

@app.route('/admin/logout')
def admin_logout():
    session.pop('admin_logged_in', None)
    return redirect(url_for('admin_login'))

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True, host='0.0.0.0', port=5000)