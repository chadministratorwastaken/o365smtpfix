Clear-Host
Write-Host "###########################################################"
Write-Host "#     Enable SMTP Client Authentication in Office 365     #"
Write-Host "###########################################################"

# Get basic info
$auth   = Get-Credential -Message "Enter the email address and password for the account"

# Establish and import a session with O365
Write-Host "[+] Establishing and importing a session with Office 365..."
$session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
           -Credential $auth -Authentication Basic -AllowRedirection
Import-PSSession $Session -DisableNameChecking -AllowClobber -ErrorAction SilentlyContinue | Out-Null

# Check SMTP Transport Authorization configuration and disable if necessary
Write-Host "[+] Checking Global and Local Configurations..."
$globalsmtp = Get-TransportConfig
$mailboxsmtp = Get-CASMailbox -Identity $auth.UserName

if ($globalsmtp.SmtpClientAuthenticationDisabled -eq $false) {
  Write-Host "[+] Global SMTP Client Authentication is enabled!"
}
else {
  Write-Host "[-] Global SMTP Client Authentication is not enabled"
  Write-Host "[-] Enabling SMTP Client Authentication globally..."
  try { Set-TransportConfig -SmtpClientAuthenticationDisabled $false }
  catch {
    Write-Host "[-] An error occurred while attempting to enable the Global SMTP Client Authentication"
    Write-Host $_.ScriptStackTrace
    }
  Write-Host "[+] Successfully enabled SMTP Client Authentication globally!"
}

if ($mailboxsmtp.SmtpClientAuthenticationDisabled -eq $false) {
  Write-Host "[+] CAS Mailbox SMTP Client Authentication is enabled!"
}
else {
  Write-Host "[-] Global SMTP Client Authentication is not enabled"
  Write-Host "[-] Enabling SMTP Client Authentication..."
  try { Set-CASMailbox -Identity $auth.UserName -SmtpClientAuthenticationDisabled $false }
  catch {
    Write-Host "[-] An error occurred while attempting to set the Mailbox SMTP Client Authentication"
    Write-Host $_.ScriptStackTrace
    }
  Write-Host "[+] Successfully enabled SMTP Client Authentication on the Mailbox!"
}

# Clear the O365 session
Write-Host "[+] Removing the Office 365 session..."
Remove-PSSession $session
Write-Host "[+] Session removed!"
Write-Host "[+] Have a great day!"