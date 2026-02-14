# HandshakeCertificate 代码详细注释

这个类用于处理X.509证书，主要用于握手过程中的证书交换和验证。下面是详细注释：

```java:HandshakeCertificate.java
import java.io.ByteArrayInputStream;
import java.io.InputStream;
import java.nio.charset.StandardCharsets;
import java.security.InvalidKeyException;
import java.security.NoSuchAlgorithmException;
import java.security.NoSuchProviderException;
import java.security.PublicKey;
import java.security.SignatureException;
import java.security.cert.CertificateEncodingException;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import java.util.stream.Collectors;
import javax.naming.NamingException;
import javax.naming.ldap.LdapName;
import javax.naming.ldap.Rdn;

/**
 * HandshakeCertificate类表示在初始握手过程中交换的X509证书
 * 提供了证书的加载、验证和信息提取功能
 */
public class HandshakeCertificate {
    // 内部保存的X509证书对象
    private X509Certificate certificate;

    /**
     * 从输入流创建证书的构造函数
     * 输入流中的数据可以是DER编码的二进制数据或Base64编码的PEM格式
     * 
     * @param instream 包含证书数据的输入流
     * @throws CertificateException 如果证书无法被解析或格式不正确
     */
    public HandshakeCertificate(InputStream instream) throws CertificateException {
        // 创建X.509证书工厂
        CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
        // 从输入流生成X509证书对象
        this.certificate = (X509Certificate) certFactory.generateCertificate(instream);
    }

    /**
     * 从字节数组创建证书的构造函数
     * 字节数组包含证书的编码表示
     * 
     * @param certBytes 包含证书数据的字节数组
     * @throws CertificateException 如果证书无法被解析或格式不正确
     */
    public HandshakeCertificate(byte[] certBytes) throws CertificateException {
        // 将字节数组转换为输入流
        ByteArrayInputStream byteStream = new ByteArrayInputStream(certBytes);
        // 创建X.509证书工厂
        CertificateFactory certFactory = CertificateFactory.getInstance("X.509");
        // 从字节输入流生成X509证书对象
        this.certificate = (X509Certificate) certFactory.generateCertificate(byteStream);
    }

    /**
     * 返回证书的编码表示（二进制形式）
     * 
     * @return 包含证书编码数据的字节数组
     * @throws CertificateEncodingException 如果证书编码失败
     */
    public byte[] getBytes() throws CertificateEncodingException {
        // 获取证书的DER编码
        return this.certificate.getEncoded();
    }

    /**
     * 返回内部的X509证书对象
     * 
     * @return X509证书对象
     */
    public X509Certificate getCertificate() {
        return this.certificate;
    }

    /**
     * 使用CA证书加密验证当前证书
     * 验证证书是否由指定的CA签发及其有效性
     * 
     * @param cacert CA证书对象
     * @throws 各种异常，如果验证失败
     */
    public void verify(HandshakeCertificate cacert) throws CertificateException, 
            NoSuchAlgorithmException, InvalidKeyException, SignatureException, 
            NoSuchProviderException {
        // 获取CA证书的公钥
        PublicKey caPublicKey = cacert.getCertificate().getPublicKey();
        // 使用CA的公钥验证当前证书
        // 如果验证失败，会抛出相应的异常
        this.certificate.verify(caPublicKey);
    }

    /**
     * 返回证书主体的CN（通用名称）
     * CN通常用于表示证书持有者的名称
     * 
     * @return 证书主体的CN，如果找不到则返回null
     */
    public String getCN() {
        // 获取证书主体的可分辨名称
        String distinguishedName = certificate.getSubjectX500Principal().getName();
        try {
            // 将可分辨名称解析为LDAP名称
            LdapName ldapName = new LdapName(distinguishedName);
            // 遍历LDAP名称的所有相对可分辨名称(RDN)
            for (Rdn rdn : ldapName.getRdns()) {
                // 检查当前RDN是否为CN类型
                if ("CN".equalsIgnoreCase(rdn.getType())) {
                    // 返回CN的值
                    return rdn.getValue().toString();
                }
            }
        } catch (NamingException e) {
            // 如果DN无法解析，处理异常
            e.printStackTrace();
        }
        return null;
    }

    /**
     * 返回证书主体的电子邮件地址
     * 在证书的主体字段中查找电子邮件地址
     * 
     * @return 证书主体的电子邮件地址，如果找不到则返回null
     */
    public String getEmail() {
        // 获取证书主体的可分辨名称
        String distinguishedName = certificate.getSubjectX500Principal().getName();
        try {
            // 将可分辨名称解析为LDAP名称
            LdapName ldapName = new LdapName(distinguishedName);
            // 遍历LDAP名称的所有相对可分辨名称(RDN)
            for (Rdn rdn : ldapName.getRdns()) {
                String type = rdn.getType();
                // 检查当前RDN是否为电子邮件地址类型
                // 可以是"EMAILADDRESS"或OID "1.2.840.113549.1.9.1"
                if ("EMAILADDRESS".equalsIgnoreCase(type) || "1.2.840.113549.1.9.1".equals(type)) {
                    Object value = rdn.getValue();
                    String result;
                    // 根据值的类型进行适当的转换
                    if (value instanceof String) {
                        result = ((String) value).trim();
                    } else if (value instanceof byte[]) {
                        // 如果是字节数组，将其转换为UTF-8字符串
                        result = new String((byte[]) value, StandardCharsets.UTF_8).trim();
                    } else {
                        continue;
                    }
                    // 调试输出：显示电子邮件地址的每个字符的十六进制值
                    System.out.println("Email characters: " + result.chars()
                        .mapToObj(ch -> String.format("0x%04X ", ch))
                        .collect(Collectors.joining()));
                    return result;
                }
            }
        } catch (NamingException e) {
            e.printStackTrace();
        }
        return null;
    }
}
```

## 主要功能与应用场景

这个类实现了以下功能：

1. **证书加载**：从输入流或字节数组加载X.509证书，支持DER和PEM格式。

2. **证书验证**：使用CA证书验证当前证书的真实性和完整性，确保证书由可信的CA签发。

3. **证书信息提取**：从证书中提取关键信息，如主体的通用名称(CN)和电子邮件地址。

4. **证书编码导出**：将证书转换为二进制编码形式，用于网络传输或存储。

## 在安全通信系统中的作用

在之前看到的NetPipeClient和NetPipeServer中，这个类被用于：

1. **身份验证**：通过证书验证通信双方的身份，防止中间人攻击。

2. **建立信任**：使用CA证书验证通信方的证书，建立信任关系。

3. **公钥交换**：通过证书安全地传输公钥，用于后续的加密和签名验证操作。

## 使用的Java API说明

1. **X509Certificate**：
   - Java证书API中表示X.509格式证书的类
   - `getEncoded()`：获取证书的DER编码
   - `verify(PublicKey)`：使用公钥验证证书
   - `getSubjectX500Principal()`：获取证书主体

2. **CertificateFactory**：
   - 用于生成证书和证书路径的工厂类
   - `getInstance("X.509")`：创建处理X.509证书的工厂
   - `generateCertificate(InputStream)`：从输入流生成证书

3. **LdapName和Rdn**：
   - 用于解析和操作LDAP名称的类
   - `LdapName(String)`：将字符串解析为LDAP名称
   - `getRdns()`：获取LDAP名称中的所有相对可分辨名称
   - `getType()`和`getValue()`：获取RDN的类型和值

这个类是安全通信系统中的关键组件，处理了证书的加载、验证和信息提取，为NetPipeClient和NetPipeServer之间的安全通信提供基础支持。


----
# HandshakeCrypto 代码详细注释

这个类提供了握手过程中所需的加密操作，主要实现了基于RSA的加密和解密功能。下面是详细注释：

```java:HandshakeCrypto.java
import java.security.Key;
import java.security.KeyFactory;
import java.security.NoSuchAlgorithmException;
import java.security.PrivateKey;
import java.security.PublicKey;
import java.security.spec.InvalidKeySpecException;
import java.security.spec.PKCS8EncodedKeySpec;
import javax.crypto.Cipher;

/**
 * HandshakeCrypto类提供安全握手过程中所需的加密操作
 * 这个实现主要关注使用公钥/私钥进行RSA加密/解密
 * 在NetPipeClient和NetPipeServer中用于安全通信的密钥交换和消息签名
 */
public class HandshakeCrypto {
    // 公钥，用于加密数据或验证签名
    private PublicKey publicKey;
    // 私钥，用于解密数据或创建签名
    private PrivateKey privateKey;
    // 使用的加密算法名称
    private static final String CRYPTO_ALGORITHM = "RSA";
    // 加密器使用的变换（算法/模式/填充）
    private static final String CIPHER_TRANSFORMATION = "RSA/ECB/PKCS1Padding";

    /**
     * 使用X509证书中的公钥创建实例
     * 这个构造函数通常在需要加密数据发送给证书所有者或验证其签名时使用
     * 
     * @param handshakeCertificate 包含公钥的证书对象
     * @throws SecurityException 如果从证书获取公钥失败
     */
    public HandshakeCrypto(HandshakeCertificate handshakeCertificate) {
        try {
            // 从证书中提取公钥
            // 调用HandshakeCertificate类的getCertificate()方法获取X509Certificate对象
            // 再调用getPublicKey()获取公钥
            this.publicKey = handshakeCertificate.getCertificate().getPublicKey();
        } catch (Exception e) {
            throw new SecurityException("Failed to initialize with certificate: " + e.getMessage());
        }
    }

    /**
     * 使用PKCS8格式的私钥字节数组创建实例
     * 这个构造函数通常在需要解密收到的数据或创建签名时使用
     * 
     * @param keyBytes 包含PKCS8格式私钥的字节数组
     * @throws SecurityException 如果私钥初始化失败
     */
    public HandshakeCrypto(byte[] keyBytes) {
        try {
            // 创建RSA密钥工厂
            KeyFactory keyFactory = KeyFactory.getInstance(CRYPTO_ALGORITHM);
            // 从字节数组创建PKCS8编码的密钥规范
            PKCS8EncodedKeySpec keySpec = new PKCS8EncodedKeySpec(keyBytes);
            // 使用密钥工厂从规范生成私钥
            this.privateKey = keyFactory.generatePrivate(keySpec);
        } catch (NoSuchAlgorithmException | InvalidKeySpecException e) {
            throw new SecurityException("Failed to initialize with private key: " + e.getMessage());
        }
    }

    /**
     * 使用已初始化的密钥解密数据
     * 如果初始化了私钥，则使用私钥解密（通常用于接收方解密收到的数据）
     * 如果初始化了公钥，则使用公钥解密（通常用于验证签名）
     * 
     * @param ciphertext 要解密的密文字节数组
     * @return 解密后的明文字节数组
     * @throws SecurityException 如果解密过程中发生错误
     */
    public byte[] decrypt(byte[] ciphertext) {
        try {
            // 创建Cipher实例，指定算法、模式和填充方式
            Cipher cipher = Cipher.getInstance(CIPHER_TRANSFORMATION);
            // 选择解密密钥（优先使用私钥，如果没有则使用公钥）
            Key decryptionKey = (privateKey != null) ? privateKey : publicKey;
            // 初始化Cipher为解密模式，并设置密钥
            cipher.init(Cipher.DECRYPT_MODE, decryptionKey);
            // 执行解密操作并返回结果
            return cipher.doFinal(ciphertext);
        } catch (Exception e) {
            throw new SecurityException("Decryption failed: " + e.getMessage());
        }
    }

    /**
     * 使用已初始化的密钥加密数据
     * 如果初始化了公钥，则使用公钥加密（通常用于发送方加密发送的数据）
     * 如果初始化了私钥，则使用私钥加密（通常用于创建签名）
     * 
     * @param plaintext 要加密的明文字节数组
     * @return 加密后的密文字节数组
     * @throws SecurityException 如果加密过程中发生错误
     */
    public byte[] encrypt(byte[] plaintext) {
        try {
            // 创建Cipher实例，指定算法、模式和填充方式
            Cipher cipher = Cipher.getInstance(CIPHER_TRANSFORMATION);
            // 选择加密密钥（优先使用公钥，如果没有则使用私钥）
            Key encryptionKey = (publicKey != null) ? publicKey : privateKey;
            // 初始化Cipher为加密模式，并设置密钥
            cipher.init(Cipher.ENCRYPT_MODE, encryptionKey);
            // 执行加密操作并返回结果
            return cipher.doFinal(plaintext);
        } catch (Exception e) {
            throw new SecurityException("Encryption failed: " + e.getMessage());
        }
    }
}
```

## 主要功能与应用场景

这个类实现了以下功能：

1. **非对称加密与解密**：使用RSA算法进行加密和解密操作。

2. **密钥管理**：支持从证书中提取公钥或直接加载PKCS8格式的私钥。

3. **签名与验证**：虽然没有显式的签名方法，但通过私钥"加密"（签名）和公钥"解密"（验证）实现了签名功能。

## 在安全通信系统中的作用

在NetPipeClient和NetPipeServer的握手过程中，HandshakeCrypto类用于：

1. **会话密钥加密**：使用对方的公钥加密会话密钥和IV，确保只有持有对应私钥的接收方能解密。

2. **消息签名**：使用自己的私钥对消息摘要进行"加密"（即创建签名），证明消息确实来自自己。

3. **签名验证**：使用对方的公钥"解密"（验证）签名，确认消息确实来自声称的发送方且未被篡改。

4. **时间戳加密**：加密时间戳信息，防止重放攻击。

## 使用的Java API说明

1. **KeyFactory**：
   - 用于从密钥规范生成密钥对象的工厂类
   - `getInstance(String algorithm)`：获取指定算法的KeyFactory实例
   - `generatePrivate(KeySpec keySpec)`：从密钥规范生成私钥

2. **PKCS8EncodedKeySpec**：
   - 表示PKCS#8标准编码格式的私钥规范
   - 构造函数接受包含编码私钥的字节数组

3. **Cipher**：
   - 提供加密和解密功能的类
   - `getInstance(String transformation)`：获取指定变换的Cipher实例
   - `init(int opmode, Key key)`：使用指定的操作模式和密钥初始化Cipher
   - `doFinal(byte[] input)`：完成加密或解密操作

4. **PublicKey和PrivateKey**：
   - 表示公钥和私钥的接口
   - 由KeyFactory生成或从证书中提取

这个类提供了强大的加密和解密功能，是安全通信系统中关键的密码学组件，为NetPipeClient和NetPipeServer之间的安全通信提供了必要的密码学操作。


---
# HandshakeDigest 代码详细注释

这个类实现了在握手过程中计算消息摘要的功能，使用SHA-256算法来确保消息的完整性。下面是详细注释：

```java:HandshakeDigest.java
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;

/**
 * HandshakeDigest类用于在握手过程中计算消息的哈希摘要
 * 使用SHA-256算法，为握手协议提供完整性保护
 * 在NetPipeClient和NetPipeServer中用于验证握手消息的完整性
 */
public class HandshakeDigest {
    // MessageDigest实例，用于计算SHA-256摘要
    private final MessageDigest messageDigest;

    /**
     * 构造函数 - 初始化一个SHA-256算法的消息摘要计算器
     * 在握手开始时创建这个对象，用于累积计算整个握手过程的消息摘要
     * 
     * @throws RuntimeException 如果SHA-256算法不可用
     */
    public HandshakeDigest() {
        try {
            // 初始化MessageDigest实例，指定使用SHA-256算法
            // SHA-256生成32字节(256位)的摘要，提供良好的安全性
            messageDigest = MessageDigest.getInstance("SHA-256");
        } catch (NoSuchAlgorithmException e) {
            // 如果系统不支持SHA-256算法，抛出运行时异常
            throw new RuntimeException("SHA-256 算法不可用", e);
        }
    }

    /**
     * 使用输入数据更新摘要计算
     * 在握手过程中，每收到或发送一个消息后调用此方法
     * 将该消息的字节表示添加到正在计算的摘要中
     * 
     * @param input 要添加到摘要计算的字节数组
     * @throws IllegalArgumentException 如果输入数据为null
     */
    public void update(byte[] input) {
        if (input == null) {
            throw new IllegalArgumentException("输入数据不能为空");
        }
        // 将输入数据添加到摘要计算中
        // 这会更新内部状态，但不会生成最终摘要
        messageDigest.update(input);
    }

    /**
     * 计算最终的消息摘要
     * 在握手过程结束时调用，生成所有累积消息的最终摘要值
     * 该摘要值用于验证握手过程中的所有消息是否完整、未被篡改
     * 
     * @return 计算得到的SHA-256摘要值的字节数组(32字节长)
     */
    public byte[] digest() {
        // 完成摘要计算并返回最终的摘要字节数组
        // 注意：调用此方法会重置MessageDigest的内部状态
        return messageDigest.digest();
    }

    /**
     * 重置摘要计算状态
     * 清除当前的摘要计算状态，可以开始一个新的摘要计算
     * 在需要重新开始计算摘要时使用
     */
    public void reset() {
        // 重置MessageDigest的内部状态
        messageDigest.reset();
    }
}
```

## 主要功能与应用场景

这个类实现了以下功能：

1. **增量式摘要计算**：可以逐步添加数据到摘要计算中，适合处理多个消息或大型数据。

2. **消息完整性验证**：通过计算消息摘要来确保数据在传输过程中没有被篡改。

3. **密码学安全支持**：使用SHA-256算法，提供较强的密码学安全性，防止碰撞攻击。

## 在安全通信系统中的作用

在NetPipeClient和NetPipeServer的握手过程中，HandshakeDigest类用于：

1. **消息累积摘要**：分别计算发送消息和接收消息的累积摘要，用于最终的签名和验证。

2. **握手完整性保护**：确保握手过程中的所有消息没有被篡改，通过在CLIENTFINISHED和SERVERFINISHED消息中包含摘要的签名。

3. **安全绑定**：握手摘要将握手过程中的所有消息绑定在一起，防止中间人攻击中的消息重排或替换。

## 使用的Java API说明

1. **MessageDigest**：
   - Java安全包中提供的消息摘要功能类
   - `getInstance(String algorithm)`：获取指定算法的MessageDigest实例
   - `update(byte[] input)`：将指定字节数组添加到摘要计算中
   - `digest()`：完成摘要计算并返回最终结果
   - `reset()`：重置摘要计算状态

在NetPipeClient和NetPipeServer的握手过程中，分别使用两个HandshakeDigest实例：

- `userDigest`：用于计算来自客户端的消息摘要
- `serverDigest`：用于计算来自服务器的消息摘要

这些摘要在握手的最后阶段（CLIENTFINISHED和SERVERFINISHED消息）中被签名并验证，以确保整个握手过程的完整性和真实性。


---
# HandshakeMessage 代码详细注释

这个类实现了握手协议中的消息定义、编码/解码和传输功能。下面是详细注释：

```java:HandshakeMessage.java
/*
 * Handshake message encoding/decoding and transmission
 * for IK2206 project.
 *
 */

import java.io.InputStream;
import java.io.OutputStream;
import java.io.ByteArrayOutputStream;
import java.io.ByteArrayInputStream;
import java.io.ObjectOutputStream;
import java.io.ObjectInputStream;
import java.io.IOException;

import java.nio.ByteBuffer;
import java.net.Socket;
import java.util.Properties;

/**
 * HandshakeMessage类表示握手过程中的消息
 * 消息被表示为一组参数 -- <键, 值>对
 * 继承自Properties类，利用其键值对存储功能
 * 在NetPipeClient和NetPipeServer中用于交换安全握手消息
 */
public class HandshakeMessage extends Properties {
    /**
     * MessageType枚举定义了握手协议中的消息类型
     * 每种类型都有一个对应的整数编码
     */
    public enum MessageType {
        CLIENTHELLO    (1),  // 客户端问候消息，包含客户端证书
        SERVERHELLO    (2),  // 服务器问候消息，包含服务器证书
        SESSION        (3),  // 会话消息，包含加密的会话密钥和IV
        CLIENTFINISHED (4),  // 客户端完成消息，包含客户端对握手的确认和签名
        SERVERFINISHED (5);  // 服务器完成消息，包含服务器对握手的确认和签名

        // 整数编码，用于消息类型的表示
        private final int code;
        
        /**
         * 构造函数，将枚举值与整数编码关联
         */
        MessageType(int code) {
            this.code = code;
        }

        /**
         * 获取消息类型的整数编码
         * @return 消息类型的整数编码
         */
        public int getCode() {
            return this.code;
        }
    }
    
    // 消息长度字段的字节宽度，用于在网络传输时表示消息长度
    static final int LENGTHBYTES = 2; // 长度字段占2字节
    
    // 当前消息的类型
    private MessageType messageType;

    /**
     * 构造函数，创建指定类型的握手消息
     * @param messageType 消息类型
     */
    public HandshakeMessage(MessageType messageType) {
        this.messageType = messageType;
    }

    /**
     * 获取消息的类型
     * @return 消息类型的枚举值
     */
    public MessageType getType() {
        return this.messageType;
    }

    /**
     * 获取消息参数的值
     * @param param 参数名
     * @return 参数值，如果参数不存在则返回null
     */
    public String getParameter(String param) {
        return this.getProperty(param);
    }

    /**
     * 设置消息参数
     * @param param 参数名
     * @param value 参数值
     */
    public void putParameter(String param, String value) {
        this.put(param, value);
    }

    /**
     * 将消息编码为字节数组
     * 使用Java的对象序列化机制，将消息对象转换为字节
     * 这些字节可以通过网络传输，然后在接收端重建消息对象
     * 
     * @return 表示消息的字节数组
     * @throws IOException 如果序列化过程出错
     */
    public byte[] getBytes() throws IOException {
        // 创建一个字节数组输出流
        ByteArrayOutputStream byteOutputStream = new ByteArrayOutputStream();
        // 创建一个对象输出流，连接到字节数组输出流
        ObjectOutputStream objectOutputStream = new ObjectOutputStream(byteOutputStream);
        // 将当前消息对象写入对象输出流
        objectOutputStream.writeObject(this);
        // 获取生成的字节数组
        byte[] bytes = byteOutputStream.toByteArray();
        return bytes;
    }

    /**
     * 从字节数组解码消息
     * 使用Java的对象反序列化机制，将字节数组转换回消息对象
     * 
     * @param bytes 包含序列化消息的字节数组
     * @return 重建的HandshakeMessage对象
     * @throws IOException 如果反序列化过程出错
     * @throws ClassNotFoundException 如果找不到序列化对象的类
     */
    public static HandshakeMessage fromBytes(byte[] bytes) throws IOException, ClassNotFoundException {
        // 创建一个字节数组输入流
        ByteArrayInputStream byteInputStream = new ByteArrayInputStream(bytes);
        // 创建一个对象输入流，连接到字节数组输入流
        ObjectInputStream objectInputStream = new ObjectInputStream(byteInputStream);
        // 从对象输入流读取消息对象
        HandshakeMessage message = (HandshakeMessage) objectInputStream.readObject();
        return message;
    }

    /**
     * 通过Socket发送握手消息
     * 先将消息编码为字节数组，然后在前面加上表示长度的2字节整数（大端序）
     * 这样接收方就能知道要读取多少字节
     * 
     * @param socket 用于发送消息的Socket连接
     * @throws IOException 如果发送过程出错
     */
    public void send(Socket socket) throws IOException {
        // 将消息编码为字节数组
        byte[] bytes = this.getBytes();
        // 创建一个2字节的数组来存储消息长度
        byte[] lengthBytes = new byte[LENGTHBYTES];
        // 创建一个大端序的ByteBuffer，用于将消息长度转换为字节
        ByteBuffer lengthBuffer = ByteBuffer.wrap(lengthBytes);
        // 将字节数组的长度(消息长度)写入ByteBuffer
        lengthBuffer.putShort(0, (short) bytes.length);
        // 获取Socket的输出流
        OutputStream output = socket.getOutputStream();
        // 先写入长度字节
        output.write(lengthBytes);
        // 再写入消息字节
        output.write(bytes);
        // 刷新输出流，确保所有数据都被发送
        output.flush();
    }

    /**
     * 从Socket接收握手消息
     * 先读取表示长度的2字节整数（大端序），然后读取相应长度的字节数组
     * 最后将字节数组转换回消息对象
     * 
     * @param socket 用于接收消息的Socket连接
     * @return 接收到的HandshakeMessage对象
     * @throws IOException 如果接收过程出错
     * @throws ClassNotFoundException 如果找不到序列化对象的类
     */
    public static HandshakeMessage recv(Socket socket) throws IOException, ClassNotFoundException {
        // 获取Socket的输入流
        InputStream input = socket.getInputStream();
        // 创建一个2字节的数组来读取消息长度
        byte[] lengthBytes = new byte[LENGTHBYTES];
        int nread;

        // 读取长度字段（2字节）
        if (LENGTHBYTES != (nread = input.read(lengthBytes, 0, LENGTHBYTES))) {
            throw new IOException("Error receiving message length");
        }
        // 创建一个大端序的ByteBuffer，用于从字节解析消息长度
        ByteBuffer lengthBuffer = ByteBuffer.wrap(lengthBytes);
        // 从ByteBuffer获取消息长度
        int length = lengthBuffer.getShort();

        // 创建一个数组来存储消息内容
        byte[] buffer = new byte[length];
        nread = 0;
        // 循环读取，直到接收到完整的消息
        while (nread < length) {
            int n = input.read(buffer, nread, length-nread);
            if (n < 0)
                throw new IOException("Error receiving message");
            nread += n;
        }
        // 从字节数组重建消息对象
        HandshakeMessage message = HandshakeMessage.fromBytes(buffer);
        return message;
    }
};
```

## 主要功能与应用场景

这个类实现了以下功能：

1. **消息类型定义**：通过枚举定义了握手协议中的各种消息类型。

2. **参数存储**：利用Properties类的功能，将消息表示为键值对的集合。

3. **消息序列化**：提供将消息对象转换为字节数组和从字节数组重建消息对象的功能。

4. **网络传输**：实现通过Socket发送和接收握手消息的功能，包括处理消息长度和完整性。

## 在安全通信系统中的作用

在NetPipeClient和NetPipeServer的握手过程中，HandshakeMessage类用于：

1. **安全信息交换**：用于在客户端和服务器之间交换证书、会话密钥和验证信息。

2. **协议流程管理**：通过不同类型的消息定义了握手协议的流程和阶段。

3. **结构化数据传输**：通过参数机制，可以在消息中包含多种类型的数据，如证书、密钥、签名等。

## 使用的Java API说明

1. **Properties**：
   - Java集合框架中的类，用于存储字符串键值对
   - HandshakeMessage继承自Properties，利用其键值对存储功能

2. **ObjectOutputStream和ObjectInputStream**：
   - Java序列化机制的核心类，用于将对象转换为字节流和从字节流重建对象
   - `writeObject(Object)`：将对象序列化到流中
   - `readObject()`：从流中读取并反序列化对象

3. **ByteArrayOutputStream和ByteArrayInputStream**：
   - 用于在内存中操作字节数组的流类
   - 作为ObjectOutputStream/ObjectInputStream的底层流，实现对象与字节数组的转换

4. **ByteBuffer**：
   - Java NIO提供的用于操作字节的缓冲区
   - 在这里用于处理消息长度的大端序表示
   - `wrap(byte[])`：将字节数组包装成ByteBuffer
   - `putShort(int, short)`：在指定位置写入short值
   - `getShort()`：读取short值

5. **Socket**：
   - 表示网络连接的套接字
   - `getInputStream()`：获取用于接收数据的输入流
   - `getOutputStream()`：获取用于发送数据的输出流

这个类是握手协议的核心组件，定义了消息格式和传输机制，为NetPipeClient和NetPipeServer之间的安全握手提供了基础设施。
