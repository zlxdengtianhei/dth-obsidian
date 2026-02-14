# NetPipeClient 代码详细注释

这是一个实现了安全通信的网络客户端代码，使用了基于证书和密钥的握手协议和加密数据传输。下面是对代码的详细注释：

```java:NetPipeClient.java
import java.io.*;
import java.net.Socket;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;

public class NetPipeClient {
    // 程序名称，用于显示使用说明
    private static String PROGRAMNAME = NetPipeClient.class.getSimpleName();
    // 存储命令行参数
    private static Arguments arguments;
    // 用于计算客户端发送消息的摘要
    private static HandshakeDigest userDigest;
    // 用于计算服务器发送消息的摘要
    private static HandshakeDigest serverDigest;
    // 客户端证书对象
    private static HandshakeCertificate clientCertificate;
    // CA证书对象，用于验证服务器证书
    private static HandshakeCertificate caCertificate;
    // 客户端私钥对象，用于签名和解密
    private static HandshakeCrypto clientPrivateKey;
    // 会话加密对象，用于加密/解密数据流
    private static SessionCipher clientCipher;

    /*
     * 显示程序使用说明并退出
     */
    private static void usage() {
        // ... 显示使用说明的代码 ...
    }

    /*
     * 解析命令行参数
     * 使用Arguments类处理命令行输入的各种参数
     */
    private static void parseArgs(String[] args) {
        // ... 解析参数的代码 ...
    }

    /*
     * 主程序入口
     * 解析命令行参数，连接服务器，并调用forwarder转发数据
     */
    public static void main(String[] args) {
        // 解析命令行参数
        parseArgs(args);

        // 获取主机和端口信息
        String host = arguments.get("host");
        int port = Integer.parseInt(arguments.get("port"));

        // 初始化证书和私钥
        try {
            initializeCertificates();
            System.out.println("[Main] Certificates and keys loaded successfully");
        } catch (Exception e) {
            System.err.println("[Main] Failed to load certificates/keys: " + e.getMessage());
            System.exit(1);
        }

        // 创建Socket连接到服务器并开始握手和数据转发
        try (Socket socket = new Socket(host, port)) {
            System.out.printf("[Main] Connected to server at %s:%d%n", host, port);

            // 执行TLS类似的握手过程
            performHandshake(socket);

            // 创建加密的数据通道并转发数据
            forwardData(socket);
        } catch (Exception e) {
            System.err.println("[Main] Client error: " + e.getMessage());
            System.exit(1);
        }
    }

    /**
     * 初始化证书和密钥
     * 从文件中加载客户端证书、CA证书和客户端私钥
     * 并初始化用于计算消息摘要的对象
     */
    private static void initializeCertificates() throws Exception {
        // 从命令行指定的文件路径加载客户端证书
        clientCertificate = new HandshakeCertificate(
                new FileInputStream(arguments.get("usercert")));
        // 从命令行指定的文件路径加载CA证书
        caCertificate = new HandshakeCertificate(
                new FileInputStream(arguments.get("cacert")));
        // 从命令行指定的文件路径加载客户端私钥
        clientPrivateKey = new HandshakeCrypto(
                new FileInputStream(arguments.get("key")).readAllBytes());

        // 创建消息摘要对象，分别用于客户端发送和接收的消息
        userDigest = new HandshakeDigest();
        serverDigest = new HandshakeDigest();
    }

    /**
     * 执行TLS类似的握手过程
     * 与服务器交换证书、建立加密会话
     */
    private static void performHandshake(Socket socket) throws Exception {
        // 1) 发送CLIENTHELLO消息，包含客户端证书
        System.out.println("[Handshake] Sending CLIENTHELLO...");
        // 创建CLIENTHELLO类型的握手消息
        HandshakeMessage clientHello = new HandshakeMessage(HandshakeMessage.MessageType.CLIENTHELLO);
        // 将客户端证书编码为Base64并添加到消息参数中
        clientHello.putParameter("Certificate",
            encodeBase64(clientCertificate.getBytes()));
        // 发送消息到服务器
        clientHello.send(socket);

        // 更新客户端发送消息的摘要
        System.out.println("[Handshake] CLIENTHELLO sent, updating userDigest...");
        userDigest.update(clientHello.getBytes());

        // 2) 接收服务器的SERVERHELLO消息
        System.out.println("[Handshake] Waiting for SERVERHELLO...");
        // 接收服务器发送的握手消息
        HandshakeMessage serverHello = HandshakeMessage.recv(socket);
        // 更新服务器发送消息的摘要
        System.out.println("[Handshake] Received SERVERHELLO, updating serverDigest...");
        serverDigest.update(serverHello.getBytes());

        // 检查接收的消息类型是否为SERVERHELLO
        if (serverHello.getType() != HandshakeMessage.MessageType.SERVERHELLO) {
            throw new Exception("[Handshake] Error: Expected SERVERHELLO message");
        }

        // 验证服务器证书
        String serverCertB64 = serverHello.getParameter("Certificate");
        // 从Base64字符串解码服务器证书
        HandshakeCertificate serverCert = new HandshakeCertificate(
                decodeBase64(serverCertB64));
        // 使用CA证书验证服务器证书的有效性
        serverCert.verify(caCertificate);
        System.out.println("[Handshake] Verified server certificate successfully");

        // 从服务器证书中获取服务器公钥
        HandshakeCrypto serverPublicKey = new HandshakeCrypto(serverCert);

        // 3) 生成会话密钥和IV，并加密后发送SESSION消息
        // 创建128位AES会话密钥
        SessionKey sessionKey = new SessionKey(128);
        // 创建会话加密对象
        clientCipher = new SessionCipher(sessionKey);

        // 使用服务器公钥加密会话密钥和IV
        byte[] encryptedKey = serverPublicKey.encrypt(sessionKey.getKeyBytes());
        byte[] encryptedIV = serverPublicKey.encrypt(clientCipher.getIVBytes());

        // 创建SESSION类型的握手消息
        HandshakeMessage sessionMsg = new HandshakeMessage(HandshakeMessage.MessageType.SESSION);
        // 将加密的会话密钥和IV添加到消息参数中
        sessionMsg.putParameter("SessionKey", encodeBase64(encryptedKey));
        sessionMsg.putParameter("SessionIV", encodeBase64(encryptedIV));
        // 发送SESSION消息到服务器
        sessionMsg.send(socket);

        // 更新客户端发送消息的摘要
        System.out.println("[Handshake] SESSION message sent, now updating userDigest...");
        userDigest.update(sessionMsg.getBytes());

        // 4) 接收并验证SERVERFINISHED消息
        System.out.println("[Handshake] Waiting for SERVERFINISHED...");
        HandshakeMessage serverFinished = HandshakeMessage.recv(socket);
        System.out.println("[Handshake] Received SERVERFINISHED");

        // 检查接收的消息类型是否为SERVERFINISHED
        if (serverFinished.getType() != HandshakeMessage.MessageType.SERVERFINISHED) {
            throw new Exception("[Handshake] Error: Expected SERVERFINISHED message");
        }

        // 验证服务器签名(服务器用私钥对serverDigest签名)
        byte[] serverSignature = decodeBase64(serverFinished.getParameter("Signature"));
        byte[] decryptedSig = serverPublicKey.decrypt(serverSignature);

        // 使用HandshakeSecurityManager验证服务器签名
        if (!HandshakeSecurityManager.verifyServerSignature(decryptedSig, serverDigest.digest())) {
            throw new Exception("[Handshake] Error: Invalid server signature in SERVERFINISHED");
        }

        // 验证服务器时间戳
        byte[] serverTimeEnc = decodeBase64(serverFinished.getParameter("TimeStamp"));
        byte[] decryptedTime = serverPublicKey.decrypt(serverTimeEnc);
        String serverTimestamp = new String(decryptedTime, "UTF-8");

        // 使用HandshakeSecurityManager验证时间戳(允许10秒钟的时差)
        HandshakeSecurityManager.verifyServerTimestamp(serverTimestamp, 10);

        System.out.println("[Handshake] SERVERFINISHED verified successfully");

        // 5) 发送CLIENTFINISHED消息
        HandshakeMessage clientFinished = new HandshakeMessage(HandshakeMessage.MessageType.CLIENTFINISHED);

        // 使用客户端私钥对客户端消息摘要进行签名
        byte[] clientSignature = clientPrivateKey.encrypt(userDigest.digest());
        // 生成当前时间戳
        String clientTS = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        // 使用客户端私钥加密时间戳
        byte[] clientTSEnc = clientPrivateKey.encrypt(clientTS.getBytes("UTF-8"));

        // 将签名和时间戳添加到CLIENTFINISHED消息中
        clientFinished.putParameter("Signature", encodeBase64(clientSignature));
        clientFinished.putParameter("TimeStamp", encodeBase64(clientTSEnc));
        // 发送CLIENTFINISHED消息到服务器
        clientFinished.send(socket);

        System.out.println("[Handshake] CLIENTFINISHED sent");
        System.out.println("[Handshake] Handshake completed successfully");
    }

    /**
     * 创建加密数据通道并转发数据
     * 使用会话密钥和IV对数据流进行加密/解密
     */
    private static void forwardData(Socket socket) throws IOException {
        System.out.println("[ForwardData] Starting data forwarding...");
        try (
            // 获取socket的输入输出流
            InputStream in = socket.getInputStream();
            OutputStream out = socket.getOutputStream();
            // 创建解密输入流和加密输出流
            InputStream decryptedIn = clientCipher.openDecryptedInputStream(in);
            OutputStream encryptedOut = clientCipher.openEncryptedOutputStream(out)
        ) {
            // 使用Forwarder类转发标准输入/输出与加密的网络流之间的数据
            Forwarder.forwardStreams(System.in, System.out, decryptedIn, encryptedOut, socket);
        }
        System.out.println("[ForwardData] Data forwarding terminated.");
    }

    /**
     * 将字节数组编码为Base64字符串
     */
    private static String encodeBase64(byte[] data) {
        return Base64.getEncoder().encodeToString(data);
    }

    /**
     * 将Base64字符串解码为字节数组
     */
    private static byte[] decodeBase64(String base64Str) {
        return Base64.getDecoder().decode(base64Str);
    }
}

/**
 * 处理握手过程中的安全验证逻辑
 */
class HandshakeSecurityManager {

    /**
     * 验证服务器签名
     * 比较解密后的签名与期望的摘要是否一致
     */
    public static boolean verifyServerSignature(byte[] decryptedSig, byte[] expectedDigest) {
        return isEqual(decryptedSig, expectedDigest);
    }

    /**
     * 验证服务器时间戳
     * 检查服务器时间与当前时间的差异是否在允许范围内
     */
    public static void verifyServerTimestamp(String timestamp, int allowedDriftSeconds) throws Exception {
        // 解析服务器时间戳
        LocalDateTime serTime = LocalDateTime.parse(
                timestamp, DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        // 获取当前时间
        LocalDateTime now = LocalDateTime.now();

        // 计算时间差(秒)
        long diffSeconds = Math.abs(java.time.Duration.between(now, serTime).getSeconds());
        // 检查时间差是否超过允许范围
        if (diffSeconds > allowedDriftSeconds) {
            throw new Exception("[Handshake] Error: Server timestamp out of ±" + allowedDriftSeconds + " second range");
        }
    }

    /**
     * 安全地比较两个字节数组是否相等
     * 使用时间恒定的比较方法防止计时攻击
     */
    private static boolean isEqual(byte[] a, byte[] b) {
        if (a == null || b == null || a.length != b.length) {
            return false;
        }
        int diff = 0;
        for (int i = 0; i < a.length; i++) {
            diff |= (a[i] ^ b[i]);
        }
        return (diff == 0);
    }
}
```

## 主要引用的外部类和函数说明

1. **HandshakeMessage** - 用于创建和处理握手协议中的消息
   - `MessageType` - 枚举类型，定义了不同类型的握手消息
   - `send(Socket)` - 发送消息到指定的socket
   - `recv(Socket)` - 从socket接收消息
   - `getBytes()` - 获取消息的字节表示
   - `putParameter(String, String)` - 添加参数到消息中
   - `getParameter(String)` - 获取消息中的参数

2. **HandshakeCertificate** - 处理X.509证书
   - 构造函数接受证书文件或字节数组
   - `getBytes()` - 获取证书的二进制表示
   - `verify(HandshakeCertificate)` - 使用CA证书验证当前证书

3. **HandshakeCrypto** - 提供非对称加密功能
   - 构造函数接受私钥或证书
   - `encrypt(byte[])` - 使用RSA加密数据
   - `decrypt(byte[])` - 使用RSA解密数据

4. **HandshakeDigest** - 计算消息摘要
   - `update(byte[])` - 更新摘要计算
   - `digest()` - 获取最终的消息摘要

5. **SessionKey** - 生成会话密钥
   - 构造函数接受密钥长度
   - `getKeyBytes()` - 获取密钥的字节表示

6. **SessionCipher** - 提供对称加密功能
   - 构造函数接受会话密钥
   - `getIVBytes()` - 获取初始化向量
   - `openEncryptedOutputStream(OutputStream)` - 创建加密输出流
   - `openDecryptedInputStream(InputStream)` - 创建解密输入流

7. **Forwarder** - 负责数据流的转发
   - `forwardStreams(InputStream, OutputStream, InputStream, OutputStream, Socket)` - 在指定的输入输出流之间转发数据

8. **Arguments** - 处理命令行参数
   - `setArgumentSpec(String, String)` - 设置参数规范
   - `loadArguments(String[])` - 从命令行加载参数
   - `get(String)` - 获取参数值

这个客户端实现了一个类似TLS的安全通信协议，包括证书验证、密钥交换、会话建立和加密数据传输。整个过程确保了通信的机密性、完整性和认证性。

----
# NetPipeServer 代码详细注释

这是一个实现了安全通信的网络服务器代码，与 NetPipeClient 对应，使用证书和密钥进行安全握手并建立加密通信通道。下面是详细注释：

```java:NetPipeServer.java
import java.io.*;
import java.net.*;
import java.time.Duration;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.Base64;

public class NetPipeServer {
    // 程序名称，用于显示使用说明
    private static String PROGRAMNAME = NetPipeServer.class.getSimpleName();
    // 存储命令行参数的对象
    private static Arguments arguments;
    // 用于计算客户端发送消息的摘要
    private static HandshakeDigest userDigest;
    // 用于计算服务器发送消息的摘要
    private static HandshakeDigest serverDigest;
    // 会话加密对象，用于加密/解密数据流
    private static SessionCipher serverCipher;
    // 服务器证书对象
    private static HandshakeCertificate serverCertificate;
    // CA证书对象，用于验证客户端证书
    private static HandshakeCertificate caCertificate;
    // 服务器私钥对象，用于签名和解密
    private static HandshakeCrypto serverPrivateKey;

    /*
     * 显示程序使用说明并退出
     */
    private static void usage() {
        // ... 显示使用说明的代码 ...
    }

    /*
     * 解析命令行参数
     * 使用Arguments类处理命令行输入的各种参数
     */
    private static void parseArgs(String[] args) {
        // 创建Arguments对象处理命令行参数
        arguments = new Arguments();
        // 设置需要的参数规范
        arguments.setArgumentSpec("port", "portnumber");
        arguments.setArgumentSpec("usercert", "server certification file");
        arguments.setArgumentSpec("cacert", "CA certification file");
        arguments.setArgumentSpec("key", "private key file");

        try {
            // 从命令行加载参数
            arguments.loadArguments(args);
        } catch (IllegalArgumentException ex) {
            // 如果参数不正确，显示使用说明
            usage();
        }
    }

    /*
     * 主程序入口
     * 解析命令行参数，等待客户端连接，并调用转发函数处理数据
     */
    public static void main(String[] args) {
        // 解析命令行参数
        parseArgs(args);
        // 获取服务器要监听的端口号
        int port = Integer.parseInt(arguments.get("port"));

        try (ServerSocket serverSocket = new ServerSocket(port)) {
            System.out.printf("[Main] Server listening on port %d%n", port);

            // 初始化证书与私钥
            initializeCertificates();
            System.out.println("[Main] Certificates and keys loaded successfully");

            // 等待客户端连接
            try (Socket socket = serverSocket.accept()) {
                System.out.println("[Main] Client connected");
                // 执行握手流程
                performHandshake(socket);
                // 正常进行数据转发
                forwardData(socket);
            }
        } catch (Exception e) {
            System.err.println("[Main] Server error: " + e.getMessage());
            System.exit(1);
        }
    }

    /**
     * 初始化证书和密钥
     * 从文件中加载服务器证书、CA证书和服务器私钥
     * 并初始化用于计算消息摘要的对象
     */
    private static void initializeCertificates() throws Exception {
        // 从指定路径加载服务器证书
        serverCertificate = new HandshakeCertificate(
                new FileInputStream(arguments.get("usercert")));
        // 从指定路径加载CA证书
        caCertificate = new HandshakeCertificate(
                new FileInputStream(arguments.get("cacert")));
        // 从指定路径加载服务器私钥
        serverPrivateKey = new HandshakeCrypto(
                new FileInputStream(arguments.get("key")).readAllBytes());
        // 创建消息摘要对象，分别用于计算客户端和服务器的消息摘要
        userDigest = new HandshakeDigest();
        serverDigest = new HandshakeDigest();
    }

    /**
     * 执行TLS类似的握手过程
     * 与客户端交换证书、建立加密会话
     */
    private static void performHandshake(Socket socket) throws Exception {
        // 1) 等待接收客户端的CLIENTHELLO消息
        System.out.println("[Handshake] Waiting for CLIENTHELLO...");
        HandshakeMessage clientHello = HandshakeMessage.recv(socket);

        // 验证消息类型是否为CLIENTHELLO
        if (clientHello.getType() != HandshakeMessage.MessageType.CLIENTHELLO) {
            throw new Exception("[Handshake] Error: Expected CLIENTHELLO message");
        }

        // 更新客户端消息的摘要
        userDigest.update(clientHello.getBytes());
        System.out.println("[Handshake] Received CLIENTHELLO and updated userDigest");

        // 2) 验证客户端证书
        String clientCertB64 = clientHello.getParameter("Certificate");
        // 从Base64字符串解码客户端证书
        HandshakeCertificate userCert = new HandshakeCertificate(
                decodeBase64(clientCertB64));
        // 使用CA证书验证客户端证书的有效性
        userCert.verify(caCertificate);
        System.out.println("[Handshake] Verified client certificate successfully");

        // 从客户端证书获取公钥
        HandshakeCrypto userPublicKey = new HandshakeCrypto(userCert);

        // 3) 发送SERVERHELLO消息
        HandshakeMessage serverHello = new HandshakeMessage(HandshakeMessage.MessageType.SERVERHELLO);
        // 添加服务器证书到消息参数
        serverHello.putParameter("Certificate",
                encodeBase64(serverCertificate.getBytes()));
        // 发送SERVERHELLO消息
        serverHello.send(socket);

        // 更新服务器消息的摘要
        System.out.println("[Handshake] Sent SERVERHELLO, now updating serverDigest...");
        serverDigest.update(serverHello.getBytes());

        // 4) 等待接收SESSION消息
        System.out.println("[Handshake] Waiting for SESSION message...");
        HandshakeMessage sessionMsg = HandshakeMessage.recv(socket);
        // 更新客户端消息的摘要
        userDigest.update(sessionMsg.getBytes());
        System.out.println("[Handshake] Received SESSION and updated userDigest");

        // 验证消息类型是否为SESSION
        if (sessionMsg.getType() != HandshakeMessage.MessageType.SESSION) {
            throw new Exception("[Handshake] Error: Expected SESSION message");
        }

        // 5) 使用服务器私钥解密会话密钥和初始化向量
        byte[] decryptedSessionKey = serverPrivateKey.decrypt(
                decodeBase64(sessionMsg.getParameter("SessionKey")));
        byte[] decryptedSessionIV = serverPrivateKey.decrypt(
                decodeBase64(sessionMsg.getParameter("SessionIV")));
        // 创建会话加密对象，使用解密后的会话密钥和IV
        serverCipher = new SessionCipher(
                new SessionKey(decryptedSessionKey), decryptedSessionIV);
        System.out.println("[Handshake] SessionKey & SessionIV decrypted successfully");

        // 6) 发送SERVERFINISHED消息
        HandshakeMessage serverFinished = new HandshakeMessage(HandshakeMessage.MessageType.SERVERFINISHED);
        // 使用服务器私钥对服务器消息摘要进行签名
        byte[] signature = serverPrivateKey.encrypt(serverDigest.digest());

        // 生成当前时间戳并使用服务器私钥加密
        String timestamp = LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));
        byte[] encryptedTimestamp = serverPrivateKey.encrypt(timestamp.getBytes("UTF-8"));

        // 添加签名和时间戳到SERVERFINISHED消息
        serverFinished.putParameter("Signature", encodeBase64(signature));
        serverFinished.putParameter("TimeStamp", encodeBase64(encryptedTimestamp));
        // 发送SERVERFINISHED消息
        serverFinished.send(socket);
        System.out.println("[Handshake] Sent SERVERFINISHED message");

        // 7) 接收并验证CLIENTFINISHED消息
        System.out.println("[Handshake] Waiting for CLIENTFINISHED...");
        HandshakeMessage clientFinished = HandshakeMessage.recv(socket);

        // 验证消息类型是否为CLIENTFINISHED
        if (clientFinished.getType() != HandshakeMessage.MessageType.CLIENTFINISHED) {
            throw new Exception("[Handshake] Error: Expected CLIENTFINISHED message");
        }

        // 8) 验证客户端签名
        byte[] clientSignature = decodeBase64(clientFinished.getParameter("Signature"));
        // 使用客户端公钥解密签名
        byte[] decryptedClientSig = userPublicKey.decrypt(clientSignature);

        // 验证解密后的签名是否与计算的客户端消息摘要一致
        if (!HandshakeSecurityManager.isEqual(decryptedClientSig, userDigest.digest())) {
            throw new Exception("[Handshake] Error: Invalid client signature in CLIENTFINISHED");
        }

        // 9) 验证客户端时间戳
        byte[] clientTimestampEnc = decodeBase64(clientFinished.getParameter("TimeStamp"));
        // 使用客户端公钥解密时间戳
        byte[] decryptedClientTime = userPublicKey.decrypt(clientTimestampEnc);
        String receivedTimestamp = new String(decryptedClientTime, "UTF-8");
        // 解析客户端时间戳
        LocalDateTime clientTime = LocalDateTime.parse(receivedTimestamp, 
                DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss"));

        // 验证客户端时间戳是否在允许的时间范围内(10秒)
        HandshakeSecurityManager.verifyTimestampInRange(
                clientTime, LocalDateTime.now(), 10, 
                "[Handshake] Error: Client timestamp out of ±10 second range");

        System.out.println("[Handshake] CLIENTFINISHED verified successfully");
        System.out.println("[Handshake] Handshake completed successfully");
    }

    /**
     * 创建加密数据通道并转发数据
     * 使用会话密钥和IV对数据流进行加密/解密
     */
    private static void forwardData(Socket socket) throws IOException {
        System.out.println("[ForwardData] Starting data forwarding...");
        try (
            // 获取socket的输入输出流
            InputStream in = socket.getInputStream();
            OutputStream out = socket.getOutputStream();
            // 创建解密输入流和加密输出流
            InputStream decryptedIn = serverCipher.openDecryptedInputStream(in);
            OutputStream encryptedOut = serverCipher.openEncryptedOutputStream(out)
        ) {
            // 使用Forwarder类转发标准输入/输出与加密的网络流之间的数据
            Forwarder.forwardStreams(System.in, System.out, decryptedIn, encryptedOut, socket);
        }
        System.out.println("[ForwardData] Data forwarding terminated.");
    }

    /**
     * 将字节数组编码为Base64字符串
     */
    private static String encodeBase64(byte[] data) {
        return Base64.getEncoder().encodeToString(data);
    }

    /**
     * 将Base64字符串解码为字节数组
     */
    private static byte[] decodeBase64(String base64Str) {
        return Base64.getDecoder().decode(base64Str);
    }

    /**
     * 内部类，提供握手过程中的安全验证功能
     */
    public class HandshakeSecurityManager {

        /**
         * 安全地比较两个字节数组是否相等
         * 使用时间恒定的比较方法防止计时攻击
         */
        public static boolean isEqual(byte[] a, byte[] b) {
            if (a == null || b == null || a.length != b.length) {
                return false;
            }
            int diff = 0;
            for (int i = 0; i < a.length; i++) {
                diff |= (a[i] ^ b[i]);
            }
            return (diff == 0);
        }
    
        /**
         * 验证两个时间戳是否在允许的时间范围内
         * @param t1 第一个时间戳
         * @param t2 第二个时间戳
         * @param allowedSeconds 允许的最大时间差(秒)
         * @param errorMessage 错误消息
         */
        public static void verifyTimestampInRange(
                LocalDateTime t1, LocalDateTime t2, long allowedSeconds, String errorMessage
        ) throws Exception {
            // 计算两个时间戳之间的秒数差
            long diffSeconds = Math.abs(Duration.between(t1, t2).getSeconds());
            // 如果时间差超过允许范围，抛出异常
            if (diffSeconds > allowedSeconds) {
                throw new Exception(errorMessage);
            }
        }
    }
}
```

## 主要引用的外部类和函数说明

1. **HandshakeMessage** - 用于创建和处理握手协议中的消息
   - `MessageType` - 枚举类型，定义了不同类型的握手消息（CLIENTHELLO, SERVERHELLO, SESSION, CLIENTFINISHED, SERVERFINISHED）
   - `send(Socket)` - 发送消息到指定的socket
   - `recv(Socket)` - 从socket接收消息
   - `getBytes()` - 获取消息的字节表示，用于摘要计算
   - `putParameter(String, String)` - 添加参数到消息中
   - `getParameter(String)` - 获取消息中的参数
   - `getType()` - 获取消息类型

2. **HandshakeCertificate** - 处理X.509证书
   - 构造函数接受证书文件流或字节数组
   - `getBytes()` - 获取证书的二进制表示
   - `verify(HandshakeCertificate)` - 使用CA证书验证当前证书的有效性

3. **HandshakeCrypto** - 提供非对称加密功能
   - 构造函数接受私钥字节数组或证书对象（获取公钥）
   - `encrypt(byte[])` - 使用RSA加密数据
   - `decrypt(byte[])` - 使用RSA解密数据

4. **HandshakeDigest** - 计算消息摘要
   - `update(byte[])` - 更新摘要计算
   - `digest()` - 获取最终的消息摘要值

5. **SessionKey** - 处理会话密钥
   - 构造函数可以接受密钥字节数组或密钥长度（自动生成密钥）
   - `getKeyBytes()` - 获取密钥的字节表示

6. **SessionCipher** - 提供对称加密功能
   - 构造函数接受会话密钥和初始化向量
   - `openEncryptedOutputStream(OutputStream)` - 创建加密输出流
   - `openDecryptedInputStream(InputStream)` - 创建解密输入流

7. **Forwarder** - 负责数据流的转发
   - `forwardStreams(InputStream, OutputStream, InputStream, OutputStream, Socket)` - 在指定的输入输出流之间转发数据

8. **Arguments** - 处理命令行参数
   - `setArgumentSpec(String, String)` - 设置参数规范
   - `loadArguments(String[])` - 从命令行加载参数
   - `get(String)` - 获取参数值

这个服务器实现了一个类似TLS的安全通信协议，包括证书验证、密钥交换、会话建立和加密数据传输。整个过程确保了通信的机密性、完整性和认证性。服务器与客户端协同工作，建立安全的通信通道。
