Set-StrictMode -Version Latest
$ErrorActionPreference='Stop'
$magic=[Text.Encoding]::ASCII.GetBytes('CCHLENC1')
function ConvertFrom-Secret([Security.SecureString]$Secret){$p=[Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secret);try{[Runtime.InteropServices.Marshal]::PtrToStringBSTR($p)}finally{[Runtime.InteropServices.Marshal]::ZeroFreeBSTR($p)}}
function Equal-Bytes([byte[]]$a,[byte[]]$b){if($a.Length -ne $b.Length){return $false};$d=0;for($i=0;$i -lt $a.Length;$i++){$d=$d -bor ($a[$i] -bxor $b[$i])};return $d -eq 0}
function Unprotect-CCHLAsset([byte[]]$Envelope,[Security.SecureString]$Passphrase){
 if($Envelope.Length -lt 92 -or -not(Equal-Bytes ([byte[]]$Envelope[0..7]) $magic)){throw 'The encrypted asset is invalid or the password is incorrect.'};[uint32]$n=[BitConverter]::ToUInt32($Envelope,8);if($n -lt 200000 -or $n -gt 10000000){throw 'The encrypted asset is invalid or the password is incorrect.'}
 $salt=New-Object byte[] 16;$iv=New-Object byte[] 16;[Array]::Copy($Envelope,12,$salt,0,16);[Array]::Copy($Envelope,28,$iv,0,16);$l=$Envelope.Length-32;$cl=$l-44;if($cl -lt 16 -or ($cl%16)){throw 'The encrypted asset is invalid or the password is incorrect.'};$auth=New-Object byte[] $l;$tag=New-Object byte[] 32;[Array]::Copy($Envelope,0,$auth,0,$l);[Array]::Copy($Envelope,$l,$tag,0,32)
 $plain=ConvertFrom-Secret $Passphrase;try{$k=New-Object Security.Cryptography.Rfc2898DeriveBytes($plain,$salt,[int]$n,[Security.Cryptography.HashAlgorithmName]::SHA256);try{$m=$k.GetBytes(64)}finally{$k.Dispose()}}finally{$plain=$null};$ek=New-Object byte[] 32;$ak=New-Object byte[] 32;[Array]::Copy($m,0,$ek,0,32);[Array]::Copy($m,32,$ak,0,32);[Array]::Clear($m,0,$m.Length)
 try{$h=[Security.Cryptography.HMACSHA256]::new($ak);try{$actual=$h.ComputeHash($auth)}finally{$h.Dispose()};if(-not(Equal-Bytes $actual $tag)){throw 'The encrypted asset is invalid or the password is incorrect.'};$ct=New-Object byte[] $cl;[Array]::Copy($Envelope,44,$ct,0,$cl);$aes=[Security.Cryptography.Aes]::Create();try{$aes.Key=$ek;$aes.IV=$iv;$aes.Mode='CBC';$aes.Padding='PKCS7';$d=$aes.CreateDecryptor();try{return ,$d.TransformFinalBlock($ct,0,$ct.Length)}finally{$d.Dispose()}}finally{$aes.Dispose()}}finally{[Array]::Clear($ek,0,32);[Array]::Clear($ak,0,32)}
}
Export-ModuleMember -Function Unprotect-CCHLAsset
