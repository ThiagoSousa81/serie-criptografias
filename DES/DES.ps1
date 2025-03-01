# Função para gerar uma chave DES
function GenerateDESParam {
    $key = New-Object byte[] 8
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($key)
    return $key
}

# Função para criptografar a mensagem usando DES
function DES-Encrypt {
    param (
        [string]$message,
        [byte[]]$key,
        [byte[]]$IV
    )
    # Transforma o texto em Bytes
    $messageBytes = [System.Text.Encoding]::UTF8.GetBytes($message)
    # Cria o CSP
    $des = [System.Security.Cryptography.DESCryptoServiceProvider]::Create()
    # Define chave e vetor
    $des.Key = $key
    $des.IV = $IV

    $encryptor = $des.CreateEncryptor() # Cria um encriptador usando o CSP    

    # Criptografa os dados
    $encryptedBytes = $encryptor.TransformFinalBlock($messageBytes, 0, $messageBytes.Length)
    
    # Devolve o resultado dos Bytes em Base64
    return [Convert]::ToBase64String($encryptedBytes)
}

# Função para descriptografar a mensagem usando DES
function DES-Decrypt {
    param (
        [string]$encryptedMessage,
        [byte[]]$key,
        [byte[]]$IV
    )
    # Retorna os dados encriptados do Base64
    $encryptedBytes = [Convert]::FromBase64String($encryptedMessage)
    
    # Cria o nosso CSP
    $des = [System.Security.Cryptography.DESCryptoServiceProvider]::Create()
    $des.Key = $key
    $des.IV = $IV

    # Cria um decriptador usando o CSP
    $decryptor = $des.CreateDecryptor()

    # Decifra os dados    
    $decryptedBytes = $decryptor.TransformFinalBlock($encryptedBytes, 0, $encryptedBytes.Length)
    
    # Devolve o resultado dos Bytes em UTF-8
    return [System.Text.Encoding]::UTF8.GetString($decryptedBytes)
}

# Exemplo de uso
$message = "HELLO"
$key = GenerateDESParam
$IV = GenerateDESParam

# Definindo uma chave e um IV fixos para testes
# $key = [byte[]](0x7E, 0x1C, 0x09, 0x6E, 0x33, 0x0A, 0x5D, 0x06)  # Chave fixa
# $IV = [byte[]](0xEF, 0x6F, 0x40, 0x80, 0x59, 0xB6, 0x16, 0xCE)  # IV fixo

$encrypted_message = DES-Encrypt -message $message -key $key -IV $IV

$decrypted_message = DES-Decrypt -encryptedMessage $encrypted_message -key $key -IV $IV

Write-Output "Message: $message"
Write-Output "Key (HEX): $([BitConverter]::ToString($key) -replace '-', '')" # Exibe a chave em formato legível
Write-Output "IV (HEX): $([BitConverter]::ToString($IV) -replace '-', '')"   # Exibe o vetor em formato legível
Write-Output "Encrypted: $encrypted_message"
Write-Output "Decrypted: $decrypted_message"
