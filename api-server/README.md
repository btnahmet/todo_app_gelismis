# Todo API Server

Bu, Todo Flutter uygulaması için RESTful API sunucusudur.

## 🚀 Özellikler

- **Authentication**: JWT tabanlı kimlik doğrulama
- **User Management**: Kullanıcı kaydı ve girişi
- **Todo Management**: CRUD operasyonları
- **API Documentation**: Swagger UI ile otomatik dokümantasyon
- **CORS Support**: Cross-origin request desteği

## 📋 Gereksinimler

- Node.js (v14 veya üzeri)
- npm

## 🛠️ Kurulum

1. **Bağımlılıkları yükleyin:**
   ```bash
   npm install
   ```

2. **Sunucuyu başlatın:**
   ```bash
   npm start
   # veya geliştirme modu için:
   npm run dev
   ```

## 🌐 API Endpoints

### Authentication
- `POST /api/auth/register` - Kullanıcı kaydı
- `POST /api/auth/login` - Kullanıcı girişi
- `POST /api/auth/logout` - Kullanıcı çıkışı

### Todos
- `GET /api/todos` - Tüm todo'ları getir
- `POST /api/todos` - Yeni todo oluştur
- `PUT /api/todos/:id` - Todo güncelle
- `DELETE /api/todos/:id` - Todo sil

### Users
- `GET /api/users/profile` - Kullanıcı profili getir
- `PUT /api/users/profile` - Kullanıcı profili güncelle

### Health Check
- `GET /api/health` - Sunucu durumu

## 📚 API Dokümantasyonu

API dokümantasyonuna erişmek için:
```
http://localhost:3001/api-docs
```

## 🔧 Konfigürasyon

### Port Değiştirme
`server.js` dosyasında `PORT` değişkenini değiştirin:
```javascript
const PORT = 3001; // İstediğiniz portu kullanın
```

### JWT Secret
Production'da `JWT_SECRET` değişkenini güvenli bir değerle değiştirin:
```javascript
const JWT_SECRET = 'your-secure-secret-key';
```

## 🗄️ Veri Saklama

Bu API sunucusu şu anda in-memory storage kullanıyor. Production için:
- MongoDB
- PostgreSQL
- MySQL
- SQLite

gibi bir veritabanı kullanmanız önerilir.

## 🔒 Güvenlik

- Şifreler bcrypt ile hash'leniyor
- JWT token'lar 24 saat geçerli
- CORS ayarları yapılandırıldı

## 🧪 Test

API'yi test etmek için:

```bash
# Health check
curl http://localhost:3001/api/health

# Kullanıcı kaydı
curl -X POST http://localhost:3001/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","email":"test@example.com","password":"password123"}'

# Kullanıcı girişi
curl -X POST http://localhost:3001/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"testuser","password":"password123"}'
```

## 📝 Lisans

MIT License
