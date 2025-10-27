#[Install Teraform Tutorial]([url](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli))

## Installation
1. Install ``gnupg`` and update
```zsh
sudo apt-get update && sudo apt-get install -y gnupg software-properties-common
```
2. Install HashiCorp's GPG key
```zsh
wget -O- https://apt.releases.hashicorp.com/gpg | \
gpg --dearmor | \
sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null
```
3. Verify the GPG key's fingerprint
```zsh
gpg --no-default-keyring \
--keyring /usr/share/keyrings/hashicorp-archive-keyring.gpg \
--fingerprint
```
Expected result from ``gpg``:
```zsh
/usr/share/keyrings/hashicorp-archive-keyring.gpg
-------------------------------------------------
pub   rsa4096 XXXX-XX-XX [SC]
AAAA AAAA AAAA AAAA
uid         [ unknown] HashiCorp Security (HashiCorp Package Signing) <security+packaging@hashicorp.com>
sub   rsa4096 XXXX-XX-XX [E]
```
4. Add the official HashiCorp repository to your system
```zsh
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(grep -oP '(?<=UBUNTU_CODENAME=).*' /etc/os-release || lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
```
5. Update apt to download the package information from the HashiCorp repository
```zsh
sudo apt update
```
6. Install Terraform from the new repository
```zsh
sudo apt-get install terraform
```
## Enable autocompletion (zsh)
1. Write zsh
```zsh
touch ~/.zshrc
```
2. Then install the autocomplete package
```zsh
terraform -install-autocomplete
```
