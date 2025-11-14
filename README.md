# Nethunt URL Extractor - Premium URL Downloader Service

A comprehensive Flask web application for downloading videos from all social media platforms including YouTube, Instagram, Facebook, TikTok, and more.

## 🚀 Features

- **Multi-Platform Support**: Download from YouTube, Instagram, Facebook, TikTok, etc.
- **User Authentication**: Secure signup/signin with Gmail-only registration
- **Free Trial System**: 1-day free trial for all new users
- **Premium Subscription**: $5/month premium access via Flutterwave payment
- **Admin Dashboard**: Complete user management system
- **Responsive Design**: Works on all devices
- **Embedded Interface**: Seamless integration with getindevice.com

## 📋 Requirements

- Python 3.7+
- Flask and dependencies (see requirements.txt)

## 🔧 Installation & Setup

### 1. Extract the Files
Extract the ZIP file to your desired location.

### 2. Install Dependencies
```bash
pip install -r requirements.txt
```

### 3. Run the Application
```bash
python run.py
```

The application will start on `http://localhost:5000`

## 👤 User Access

### Sign Up
- Visit `http://localhost:5000/signup`
- Use any Gmail address (must end with @gmail.com)
- Create a secure password

### Sign In
- Visit `http://localhost:5000/signin`
- Enter your Gmail and password

### Free Trial
- All new users get 1-day free trial
- Unlimited downloads during trial period
- After trial expires, users must upgrade to premium

## 💳 Premium Access

### Payment Process
1. Click "Upgrade to Premium" or wait for trial to expire
2. Redirect to Flutterwave payment: `https://flutterwave.com/pay/7k8wh62jmtzh`
3. After successful payment, redirect to `https://nerhggf.com` (your domain)
4. Premium access is automatically activated for 30 days

### Premium Features
- Unlimited downloads from all platforms
- No advertisements
- Priority support
- HD quality downloads

## 🔐 Admin Access

### Admin Login
- URL: `http://localhost:5000/admin/login`
- Username: `nethunter`
- Password: `cbtpratice@nethunter`

### Admin Features
- View all registered users
- Monitor premium subscriptions
- Grant premium access manually
- Revoke premium access if needed
- User statistics and analytics

## 📁 Project Structure

```
nethunt-url-extractor/
├── app.py                 # Main Flask application
├── run.py                 # Application runner
├── requirements.txt       # Python dependencies
├── README.md             # Setup instructions
├── templates/            # HTML templates
│   ├── base.html         # Base template
│   ├── signup.html       # User registration
│   ├── signin.html       # User login
│   ├── dashboard.html    # User dashboard
│   ├── payment.html      # Payment/upgrade page
│   ├── admin_login.html  # Admin login
│   └── admin_dashboard.html # Admin dashboard
└── nethunt.db           # SQLite database (auto-created)
```

## 🚀 Deployment

### Local Development
```bash
python run.py
```

### Production Deployment
1. Set up a production web server (Gunicorn, uWSGI)
2. Configure a reverse proxy (Nginx, Apache)
3. Set up SSL certificates
4. Update the redirect URL in app.py to your production domain
5. Configure environment variables for security

### Environment Variables
```bash
export FLASK_ENV=production
export SECRET_KEY='your-production-secret-key'
```

## 🔧 Configuration

### Flutterwave Integration
- Payment link: `https://flutterwave.com/pay/7k8wh62jmtzh`
- Success redirect: `https://nerhggf.com/payment-success`
- Update these URLs in `app.py` for your domain

### Database
- Uses SQLite by default (`nethunt.db`)
- Auto-created on first run
- Can be switched to PostgreSQL/MySQL for production

## 🛡️ Security Features

- Password hashing with Werkzeug
- Session management with Flask-Login
- CSRF protection
- Input validation
- Gmail-only registration restriction

## 📱 Supported Platforms

- YouTube
- Instagram (Posts, Reels, Stories)
- Facebook (Videos, Posts)
- TikTok
- Twitter
- Vimeo
- And many more...

## 🎨 Design Features

- Modern gradient design
- Responsive layout
- Mobile-friendly interface
- Smooth animations
- Professional UI/UX

## 🔄 Trial & Subscription System

- **Free Trial**: 1 day unlimited access
- **Premium**: $5/month (30 days)
- **Yearly**: $50/year (save $10)
- **Automatic Expiration**: Access ends when period expires
- **Manual Override**: Admin can grant/revoke premium access

## 📞 Support

For technical support or questions:
- Email: support@nethunt.com
- Admin: Use the admin panel for user management

## 📄 License

© 2024 Nethunt URL Extractor. All rights reserved.

---

**Note**: This application is ready for deployment on any server that supports Python and Flask. The database is auto-created, and all dependencies are included in requirements.txt.