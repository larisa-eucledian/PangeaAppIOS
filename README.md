# 📱 PangeaApp — Borderless Connection  
_Ecommerce de travel eSIMs para iOS_

![Platform](https://img.shields.io/badge/platform-iOS-blue)
![Swift](https://img.shields.io/badge/swift-5.0+-orange)
![UIKit](https://img.shields.io/badge/framework-UIKit-purple)
![Stripe](https://img.shields.io/badge/payments-Stripe-626CD9)
![License](https://img.shields.io/badge/license-MIT-green)
![Status](https://img.shields.io/badge/status-MVP%20Ready-brightgreen)

---

## 📌 Objetivo del App
PangeaApp es una aplicación iOS que permite a los usuarios:

- Explorar países y paquetes de eSIM.
- Comprar eSIMs mediante **Stripe PaymentSheet** (modo pruebas disponible).
- Visualizar sus eSIMs compradas, con estado, vigencia y detalle.
- Activar eSIMs desde el app.
- Instalar la eSIM con integración rápida en iOS (si aplica).
- Consultar el **uso de datos en tiempo real** tras la activación.
- Autenticarse mediante registro, login, logout y recuperación de contraseña.

Esta app se basa en la documentación oficial del proyecto PANGEA:
- Acta del Proyecto :contentReference[oaicite:0]{index=0}  
- Elevator Pitch del Proyecto :contentReference[oaicite:1]{index=1}  

---

## 🌐 Logo y Significado
El logo representa **Pangea**, el supercontinente que unificó todas las masas terrestres.

Simboliza:

- Conectividad global  
- Un mundo sin fronteras  
- Tecnología que une viajeros de todo el planeta  

**Slogan:** _Borderless Connection_

---

## 📲 Dispositivos, Versión de iOS y Orientación Soportada

### **📱 Dispositivo**
Compatible con iPhone que tenga soporte de eSIM nativamente:

- iPhone XS / XS Max / XR  
- iPhone 11, 12, 13, 14, 15  
Referencia técnica: https://support.apple.com/en-us/118669

### **🎛 Versión mínima**
- iOS **15+**

### **📐 Orientación**
- **Solo portrait**  
Justificación: la app usa listas y flujos verticales, lo cual optimiza la usabilidad y el diseño sin necesidad de landscape.

---

## 🔐 Acceso para Evaluación

### Crear cuenta
Disponible desde el flujo de registro.

### Usuario de prueba (revisado por profesores)
Email: gkl@gkl.de
Contraseña: 12345678


### Datos de tarjeta (Stripe - pruebas)
Número: 4242 4242 4242 4242
CVC: Cualquier 3 dígitos
Fecha: Cualquier mes/año futuro


---

## 🧩 Dependencias del Proyecto

| Dependencia | Uso |
|------------|-----|
| **CoreData** | Cache de países, paquetes y eSIMs |
| **Keychain** | Almacenamiento seguro de token JWT |
| **Stripe iOS SDK** | PaymentSheet, Payment Intents |
| **UIKit (Storyboard)** | Interfaz nativa |
| **DiffableDataSource** | Manejo eficiente de listas |

---

## 🧱 Arquitectura del Proyecto

### 🏗 Patrón General
- Arquitectura modular por features
- Networking nativo (URLSession con async/await)
- Persistencia híbrida (CoreData + cache en memoria)
- Manejo seguro de sesión con Keychain


---

## 🧪 Flujos recomendados para testing

1. Registro → Login  
2. Explorar países  
3. Seleccionar un paquete  
4. Compra con tarjeta de prueba  
5. Revisar la eSIM creada en “Mis eSIMs”  
6. Activar eSIM  
7. Obtener el método de instalación  
8. Ver el uso de datos en tiempo real  

¡OJO LAS ESIMS GENERADAS SON DE PRUEBAS, NO SE PUEDEN INSTALAR NI TIENEN SERVICIO!

---
