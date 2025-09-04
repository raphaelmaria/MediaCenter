# Fail 2 Ban Linux

## Guia de Instalação do Fail2Ban no Linux


Configurar o **Fail2Ban** no seu servidor Linux (como o Debian) é uma forma poderosa de proteger contra ataques de força bruta e acessos indevidos. A seguir, apresento um guia prático e direto, mas também elegante, como se fosse um ritual de fortificação de seu castelo digital.

---

### 🛡️ **Passo 1: Instalar o Fail2Ban**

No Debian ou derivados:

```bash
sudo apt update
sudo apt install fail2ban -y
```

---

### 🛠️ **Passo 2: Criar uma cópia da configuração padrão**

Nunca edite o arquivo original diretamente. Em vez disso, crie um arquivo `.local` para suas regras personalizadas:

```bash
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
```

---

### ⚙️ **Passo 3: Editar as configurações**

Abra o arquivo com seu editor favorito:

```bash
sudo nano /etc/fail2ban/jail.local
```

Procure pela seção `[DEFAULT]` e ajuste os valores básicos:

```ini
[DEFAULT]
bantime = 1h
findtime = 10m
maxretry = 5
backend = systemd
```

* `bantime`: Tempo que o IP ficará bloqueado (ex: `1h` = 1 hora).
* `findtime`: Janela de tempo para considerar os acessos (ex: 10 minutos).
* `maxretry`: Número máximo de tentativas antes do banimento.

---

### 🔐 **Passo 4: Ativar uma jail**

Por exemplo, para proteger **SSH**:

```ini
[sshd]
enabled = true
port    = ssh
logpath = %(sshd_log)s
backend = systemd
```

---

### 🧪 **Passo 5: Testar e iniciar o serviço**

Reinicie o serviço:

```bash
sudo systemctl restart fail2ban
```

Habilite para iniciar com o sistema:

```bash
sudo systemctl enable fail2ban
```

Verifique o status:

```bash
sudo fail2ban-client status
```

Verifique jails ativas (exemplo para SSH):

```bash
sudo fail2ban-client status sshd
```

---

### ✏️ **(Opcional) Criar regras personalizadas**

Você pode proteger qualquer serviço com logs. Por exemplo, proteger o **Nginx** contra tentativas maliciosas:

1. Criar um arquivo de configuração:

```bash
sudo nano /etc/fail2ban/jail.d/nginx.local
```

2. Conteúdo básico para bloquear erros repetidos 403/404:

```ini
[nginx-http-auth]
enabled = true
port     = http,https
filter   = nginx-http-auth
logpath  = /var/log/nginx/error.log
maxretry = 3
```

3. Certifique-se de que o filtro existe em `/etc/fail2ban/filter.d/`.

---

### 📜 Para verificar IPs banidos:

```bash
sudo fail2ban-client status sshd
```

---

Se quiser posso te ajudar a criar regras específicas para nginx, FTP, Apache, ou qualquer outro serviço.

Deseja proteger algo além do SSH?

consigo fazer o mesmo processo so com portas como base, queria aplicar nas portas 7878, 8989 e 9114

Sim, Raphael, é perfeitamente possível — e até prudente — criar regras no **Fail2Ban** com base em conexões tentadas diretamente por **portas específicas**, mesmo que o serviço não esteja registrando logs com erros claros.

Como o Fail2Ban normalmente depende de **logs com padrões detectáveis**, quando você quer agir com base em **portas** e **comportamento de conexão** (como tentativas indevidas ou fora do esperado), o ideal é usar o **`sshd` ou o `iptables` como back-end de detecção**. Aqui está o caminho das pedras:

---

## 🔥 **Objetivo:** Banir IPs que tentarem conexão nas portas 7878, 8989 e 9114 se fizerem várias tentativas em um curto período.

---

### 1. **Habilitar logging de pacotes rejeitados com iptables**

Certifique-se de que as conexões indesejadas estão sendo registradas. Um exemplo:

```bash
sudo iptables -A INPUT -p tcp --dport 7878 -j LOG --log-prefix "F2B_7878 "
sudo iptables -A INPUT -p tcp --dport 8989 -j LOG --log-prefix "F2B_8989 "
sudo iptables -A INPUT -p tcp --dport 9114 -j LOG --log-prefix "F2B_9114 "
```

Essas regras apenas **logam**, não bloqueiam.

Verifique se o log está indo para `/var/log/syslog`, `/var/log/messages` ou `/var/log/kern.log`, dependendo da distro.

---

### 2. **Criar filtros customizados**

#### `/etc/fail2ban/filter.d/port-7878.conf`

```ini
[Definition]
failregex = ^.*F2B_7878 .*SRC=<HOST>.*$
ignoreregex =
```

#### `/etc/fail2ban/filter.d/port-8989.conf`

```ini
[Definition]
failregex = ^.*F2B_8989 .*SRC=<HOST>.*$
ignoreregex =
```

#### `/etc/fail2ban/filter.d/port-9114.conf`

```ini
[Definition]
failregex = ^.*F2B_9114 .*SRC=<HOST>.*$
ignoreregex =
```

---

### 3. **Criar jails para cada porta**

No seu `/etc/fail2ban/jail.local`:

```ini
[port-7878]
enabled  = true
filter   = port-7878
logpath  = /var/log/kern.log   # ou /var/log/syslog
bantime  = 3600
findtime = 300
maxretry = 3
action   = iptables[name=port-7878, port=7878, protocol=tcp]

[port-8989]
enabled  = true
filter   = port-8989
logpath  = /var/log/kern.log
bantime  = 3600
findtime = 300
maxretry = 3
action   = iptables[name=port-8989, port=8989, protocol=tcp]

[port-9114]
enabled  = true
filter   = port-9114
logpath  = /var/log/kern.log
bantime  = 3600
findtime = 300
maxretry = 3
action   = iptables[name=port-9114, port=9114, protocol=tcp]
```

> **Obs.** Altere `logpath` se necessário — use `sudo tail -f /var/log/syslog` ou `dmesg` para verificar onde os logs do `LOG --log-prefix` estão indo.

---

### 4. **Recarregar o Fail2Ban**

```bash
sudo systemctl restart fail2ban
```

Verifique se tudo está ativo:

```bash
sudo fail2ban-client status
sudo fail2ban-client status port-7878
```

---

### 🌾 Considerações Finais

Esse método é útil para:

* Serviços web como **Radarr**, **Sonarr**, **Bazarr**, **Prometheus exporters**, que não possuem logs de segurança robustos.
* Defender portas silenciosas que **não respondem**, mas são sondadas.

Se quiser, posso te ajudar a integrar isso com um **script de alerta no Telegram** ou até enviar os IPs bloqueados para um blacklist compartilhado.

Perfeito, Raphael. Como um vigia atento na madrugada digital, podemos fazer com que **toda tentativa bloqueada** acenda um farol e envie um alerta até seu **Telegram**, para que você saiba — em tempo real — que houve atividade suspeita nas portas sensíveis do seu castelo.

Abaixo, descrevo como montar esse **sistema de notificação via Telegram** e, se quiser, também como alimentar um **blacklist.txt** local com os IPs bloqueados.

---

## 🌐 Parte 1 — Notificações via Telegram

### 1.1 Obter o Token do Bot e ID do Chat

Siga estes passos:

1. No Telegram, busque por `@BotFather`.

2. Crie um novo bot com `/newbot`.

3. Ele vai te dar um token como:

   ```
   123456789:ABCdefGHIjklMNOpqrSTUvwxYZ12345678
   ```

4. Vá até `https://api.telegram.org/bot<token>/getUpdates` (substitua `<token>` pelo seu token real).

5. Envie uma mensagem qualquer para o bot.

6. Veja no JSON retornado o campo `"chat":{"id":<seu_id>}` — este é o `CHAT_ID`.

---

### 1.2 Criar Script `/etc/fail2ban/scripts/telegram_notify.sh`

```bash
#!/bin/bash

TOKEN="123456789:ABCdefGHIjklMNOpqrSTUvwxYZ12345678"
CHAT_ID="123456789"
TEXT="$1"

curl -s -X POST "https://api.telegram.org/bot$TOKEN/sendMessage" \
     -d chat_id="$CHAT_ID" \
     -d text="$TEXT" \
     -d parse_mode="Markdown"
```

**Torne o script executável:**

```bash
sudo chmod +x /etc/fail2ban/scripts/telegram_notify.sh
```

---

### 1.3 Criar Ação Personalizada `/etc/fail2ban/action.d/telegram.conf`

```ini
[Definition]
actionstart =
actionstop =
actioncheck =
actionban = /etc/fail2ban/scripts/telegram_notify.sh "🚨 IP banido pelo Fail2Ban: <ip> na jail <name>"
actionunban =
```

---

### 1.4 Usar no `jail.local`

Exemplo:

```ini
[port-7878]
enabled  = true
filter   = port-7878
logpath  = /var/log/kern.log
bantime  = 3600
findtime = 300
maxretry = 3
action   = iptables[name=port-7878, port=7878, protocol=tcp]
           telegram[name=port-7878]
```

> Isso envia o IP banido para o seu Telegram quando a regra for acionada.

---

## 📂 Parte 2 — Adicionar IPs Banidos a um `blacklist.txt`

Crie o script `/etc/fail2ban/scripts/add_to_blacklist.sh`:

```bash
#!/bin/bash

BLACKLIST="/var/log/fail2ban/blacklist.txt"
IP="$1"
DATE=$(date +'%Y-%m-%d %H:%M:%S')

echo "$DATE - $IP" >> "$BLACKLIST"
```

Deixe executável:

```bash
chmod +x /etc/fail2ban/scripts/add_to_blacklist.sh
```

E adicione no mesmo `jail.local`:

```ini
action   = iptables[name=port-7878, port=7878, protocol=tcp]
           telegram[name=port-7878]
           %(mta)s[name=Fail2Ban]
           /etc/fail2ban/scripts/add_to_blacklist.sh <ip>
```

---

## 🧪 Testar

Depois que configurar, simule um log de tentativa de acesso ou force uma entrada que se encaixe no `failregex` para confirmar que:

* O IP é banido.
* A mensagem chega ao seu Telegram.
* O IP é adicionado ao arquivo `blacklist.txt`.

---





## ERRO - Jail does not exist
raphaelmaria@mediacenter:~$ sudo fail2ban-client status python-http
2025-08-02 20:46:47,087 fail2ban                [43554]: ERROR   NOK: ('python-http',)
Sorry but the jail 'python-http' does not exist

Essa mensagem de erro informa que o **Fail2Ban não encontrou nenhuma cadeia (jail) chamada `python-http`**, o que pode acontecer por dois motivos principais:

---

### 🧭 1. A jail `python-http` não está definida no seu `jail.local`

Você precisa primeiro garantir que há uma seção semelhante a esta no arquivo:

```ini
[python-http]
enabled  = true
port     = 8000
filter   = python-http
logpath  = /var/log/python-http.log
maxretry = 5
```

> 🔍 Verifique se você tem uma seção `[python-http]` no seu `/etc/fail2ban/jail.local`.

---

### 🧰 2. O filtro `python-http.conf` também precisa existir

No diretório `/etc/fail2ban/filter.d/`, deve haver um arquivo chamado `python-http.conf`, que contenha as **expressões regulares (regex)** para identificar tentativas de ataque ou falhas de autenticação no log.

#### Exemplo básico de filtro:

Crie o arquivo com:

```bash
sudo nano /etc/fail2ban/filter.d/python-http.conf
```

E adicione, por exemplo:

```ini
[Definition]
failregex = ^.*Invalid login attempt.*$
ignoreregex =
```

Ajuste a regex conforme o conteúdo real do seu log.

---

### ✅ Checklist para a jail funcionar:

| Requisito                 | Caminho                    | Observação                 |
| ------------------------- | -------------------------- | -------------------------- |
| Seção `[python-http]`     | `/etc/fail2ban/jail.local` | Define a jail              |
| Filtro `python-http.conf` | `/etc/fail2ban/filter.d/`  | Define o padrão de falha   |
| Log monitorado            | `/var/log/python-http.log` | Deve existir e estar ativo |
| Jail habilitada           | `enabled = true`           | Necessário para funcionar  |

---

### 🔄 Após configurar:

1. **Verifique a configuração:**

```bash
sudo fail2ban-client -d
```

2. **Reinicie o serviço:**

```bash
sudo systemctl restart fail2ban
```

3. **Cheque o status novamente:**

```bash
sudo fail2ban-client status python-http
```

Se quiser, posso te ajudar a montar um `filter` com base em um trecho do log real do seu servidor Python. É só colar um exemplo aqui.
