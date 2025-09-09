# 🚀 Desafio: Automatização de Backup

![Shell Script](https://img.shields.io/badge/Language-Shell%20Script-orange)
![Status](https://img.shields.io/badge/Status-Ready-brightgreen)

Este repositório contém **scripts de automação de backup** (atualmente configurados para o diretório `/home/valcann/backupsFrom`, mas facilmente personalizáveis através das variáveis de configuração).  

---

## 📂 Scripts

- 💡 Observações sobre Filesystem (FS)

  * `birth time` (`stat -c %w`) → utilizado quando disponível.
  * `ctime` (`stat -c %z`) → alternativa quando `birth time` não está disponível, garantindo compatibilidade com diversos filesystems (ex: ext3, FAT32, NFS).
  * 🔧 Rótulo dinâmico mantendo consistência com o metadado disponível **Criado/Alterado**.

---

## ⚙️ Variáveis de configuração

- `SOURCE_DIR="/home/valcann/backupsFrom"`   # Diretório de origem
- `DEST_DIR="/home/valcann/backupsTo"`       # Diretório de destino 
- `LOG_FROM="/home/valcann/backupsFrom.log"` # Log da origem
- `LOG_TO="/home/valcann/backupsTo.log"`     # Log do destino

> O script cria automaticamente o diretório de destino caso não exista (`DEST_DIR`).

---

### 1️⃣ `backupFiles.sh` (não recursivo)

- 🗂️ Processa **apenas arquivos** diretamente no diretório de origem.
- Funcionalidades:
  - Lista arquivos com **nome, tamanho, datas de criação/alteração e última modificação**.
  - Remove arquivos com **mais de 3 dias**.
  - Copia arquivos com **até 3 dias** para o diretório de destino (`DEST_DIR`).
  - Gera logs:
    - `backupsFrom.log` → arquivos listados + remoção de antigos.
    - `backupsTo.log` → arquivos copiados recentemente.

**Exemplo de execução:**

```bash
chmod +x backupFiles.sh
./backupFiles.sh
```

---

### 2️⃣ `backupRecursive.sh` (recursivo)

* 🔄 Processa **arquivos e pastas**, incluindo todas as subpastas.

* Funcionalidades:

  * Lista todos os itens (Arquivos/Pastas/Outros) com tipo, tamanho e datas.
  * Remove arquivos/pastas com **mais de 3 dias**.
  * Copia arquivos/pastas com **até 3 dias**, mantendo a **estrutura de diretórios**.
  * Gera logs detalhados:

    * `backupsFrom.log` → listagem completa + remoção.
    * `backupsTo.log` → itens copiados recentemente.

**Exemplo de execução:**

```bash
chmod +x backupRecursive.sh
./backupRecursive.sh
```

---

## 📝 Logs gerados

1. **backupsFrom.log**

   * Lista de arquivos/pastas analisados.
   * Itens removidos com mais de 3 dias.

2. **backupsTo.log**

   * Lista de arquivos/pastas copiados recentemente (≤3 dias).
   * Data e hora de conclusão do processo.


<br>
<br>

---
---

# 🧠 Bill Gates disse que gosta de contratar preguiçosos, aplique um Cron Job no seu script!

---
---

## ⏰ Agendando com `cron`

Um **Cron Job** consiste em automatizar a execução dos scripts usando o **cron**, o agendador de tarefas do Linux.

### 📌 Passos para configurar

1. **Dê permissão de execução ao script**:

   ```bash
   chmod +x /home/valcann/backupRecursive.sh
   ```
    Ou (a depender do script que deseja usar)

   ```bash
   chmod +x /home/valcann/backupFiles.sh
   ```

2. **Abra o editor do `cron`**:

   ```bash
   crontab -e
   ```

3. **Adicione a linha de agendamento** (exemplo: rodar todo dia após seu termino de trabalho com o script recursivo):

   ```bash
   0 2 * * * /home/valcann/backupRecursive.sh >> /home/valcann/cron_backup.log 2>&1
   ```

   🔎 **Detalhes**:

   * `0` → minuto
   * `2` → hora (**02:00 da manhã** Sim, eu sei que você é workaholic e trabalha até essa hora 🤤)
   * `*` → todos os dias do mês
   * `*` → todos os meses
   * `*` → todos os dias da semana

   O trecho `>> /home/valcann/cron_backup.log 2>&1` salva **toda a saída e erros** no log `cron_backup.log` (criado automaticamente se não existir).

---

### ⏳ Exemplos de agendamento concretos

* **A cada hora**

  ```bash
  0 * * * * /home/valcann/backupFiles.sh >> /home/valcann/cron_backup.log 2>&1
  ```

* **Todo dia às 23h30**

  ```bash
  30 23 * * * /home/valcann/backupRecursive.sh >> /home/valcann/cron_backup.log 2>&1
  ```

* **Toda segunda-feira às 08h00**

  ```bash
  0 8 * * 1 /home/valcann/backupRecursive.sh >> /home/valcann/cron_backup.log 2>&1
  ```

* **A cada 10 minutos**

  ```bash
  */10 * * * * /home/valcann/backupFiles.sh >> /home/valcann/cron_backup.log 2>&1
  ```