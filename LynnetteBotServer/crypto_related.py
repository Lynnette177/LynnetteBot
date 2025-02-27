from Crypto.Cipher import AES
from Crypto.Util.Padding import pad
import base64


def aes_encrypt_base64_base64(key: bytes, data: str) -> str:
    # 创建AES加密对象，使用ECB模式
    cipher = AES.new(key, AES.MODE_ECB)
    # 将数据填充至AES块大小（16字节）
    padded_data = pad(data.encode(), AES.block_size)
    # 执行加密操作
    encrypted_data = cipher.encrypt(padded_data)
    # 使用Base64进行编码
    encrypted_base64 = base64.b64encode(encrypted_data).decode('utf-8')
    encrypted_base64 = base64.b64encode(encrypted_base64.encode()).decode('utf-8')
    return encrypted_base64