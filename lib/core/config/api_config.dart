class ApiConfig {
  ApiConfig._();

  // Fiziksel telefondan test ederken localhost çalışmaz — bilgisayarınızın
  // yerel ağ IP'sini yazın (Mac'te terminalde: ifconfig | grep "inet ")
  static const String baseUrl =
      'http://localhost:8080/api'; //'http://172.20.10.3:8080/api'; //'http://192.168.1.X:8080/api';
}
