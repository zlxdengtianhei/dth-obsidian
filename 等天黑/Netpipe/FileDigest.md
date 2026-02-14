# FileDigest 代码详细注释

这是一个计算文件 SHA-256 摘要并以 Base64 编码输出的工具。下面是详细注释：

```java:FileDigest.java
import java.io.*;               // 导入输入输出相关类
import java.security.*;         // 导入安全相关类，包含MessageDigest
import java.util.Base64;        // 导入Base64编码解码功能

/**
 * FileDigest类：用于计算文件的SHA-256摘要并以Base64编码形式输出
 * 这个工具可以用于验证文件完整性，例如通过比较两个文件的摘要值来确定它们是否相同
 */
public class FileDigest {
    /**
     * 主方法：程序入口
     * @param args 命令行参数，应包含一个参数：要计算摘要的文件路径
     */
    public static void main(String[] args) {
        // 检查命令行参数数量是否正确
        if (args.length != 1) {
            // 如果参数数量不正确，显示使用说明并退出程序
            System.err.println("Usage: java FileDigest <filename>");
            System.exit(1);
        }

        try {
            // 创建SHA-256消息摘要实例
            // MessageDigest类提供了用于计算消息摘要的功能
            // getInstance方法接受一个算法名称，返回该算法的MessageDigest对象
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            
            // 打开文件输入流读取文件内容
            try (FileInputStream fis = new FileInputStream(args[0])) {
                // 创建缓冲区以高效读取文件
                byte[] buffer = new byte[8192];  // 8KB大小的缓冲区
                int bytesRead;  // 每次读取的字节数
                
                // 逐块读取文件并更新摘要计算
                // read方法返回读取的字节数，如果到达文件末尾则返回-1
                while ((bytesRead = fis.read(buffer)) != -1) {
                    // 使用update方法将读取的字节块添加到摘要计算中
                    // 参数：要添加的字节数组，起始位置，长度
                    md.update(buffer, 0, bytesRead);
                }
                // try-with-resources会自动关闭FileInputStream
            }
            
            // 完成摘要计算并获取最终的摘要值
            // digest方法完成摘要计算并返回计算结果的字节数组
            byte[] digest = md.digest();
            
            // 将二进制摘要值转换为Base64编码的字符串
            // Base64编码使二进制数据可以用ASCII字符表示，便于传输和显示
            String base64Digest = Base64.getEncoder().encodeToString(digest);
            
            // 输出Base64编码的摘要值到标准输出
            System.out.println(base64Digest);
            
        } catch (NoSuchAlgorithmException e) {
            // 如果指定的摘要算法不可用，捕获并处理异常
            System.err.println("Error: " + e.getMessage());
            System.exit(1);
        } catch (IOException e) {
            // 如果文件读取出错，捕获并处理异常
            System.err.println("Error: " + e.getMessage());
            System.exit(1);
        }
    }
}
```

## 主要功能与应用场景

这个程序实现了以下功能：

1. **文件完整性验证**：计算文件的SHA-256摘要值，可用于验证文件在传输或存储过程中是否被修改。

2. **数据指纹生成**：为文件生成唯一的"指纹"，可用于快速比较两个文件是否相同，而无需比较整个文件内容。

3. **安全应用**：在密码学和安全相关应用中，摘要值常用于验证数据的完整性和真实性。

## 使用的Java API说明

1. **MessageDigest**：
   - Java安全包中提供的类，用于计算消息摘要
   - `getInstance(String algorithm)`：创建指定算法的MessageDigest实例
   - `update(byte[] input, int offset, int len)`：将指定字节数组的部分内容添加到当前摘要
   - `digest()`：完成摘要计算并返回摘要值的字节数组

2. **FileInputStream**：
   - 用于读取文件内容的输入流
   - `read(byte[] b)`：将文件内容读入字节数组，返回读取的字节数

3. **Base64**：
   - Java 8引入的Base64编码解码工具类
   - `getEncoder()`：获取Base64编码器
   - `encodeToString(byte[] src)`：将字节数组编码为Base64字符串

这个程序是一个简单但实用的工具，可以与我们之前看到的NetPipeClient和NetPipeServer配合使用，例如在建立安全通信前验证证书文件或密钥文件的完整性。
