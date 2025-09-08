#!/bin/bash

# Diretórios
SOURCE_DIR="/home/valcann/backupsFrom"
DEST_DIR="/home/valcann/backupsTo"
LOG_FROM="/home/valcann/backupsFrom.log"
LOG_TO="/home/valcann/backupsTo.log"

# Cria diretório de destino, se não existir
mkdir -p "$DEST_DIR"

# Cabeçalho do log de origem
echo "===== Relatório backupsFrom $(date '+%Y-%m-%d %H:%M:%S') =====" > "$LOG_FROM"

# Listar arquivos com nome, tamanho, datas
for file in "$SOURCE_DIR"/*; do
    if [ -f "$file" ]; then
        name=$(basename "$file")
        size=$(stat -c%s "$file")

        # Tenta pegar a data de criação (birth time)
        created=$(stat -c %w "$file" 2>/dev/null)

        # Se não existir, usa a última alteração de metadados
        if [ "$created" = "-" ] || [ -z "$created" ]; then
            created=$(stat -c %z "$file")
            label="Alterado"
        else
            label="Criado"
        fi

        # Última modificação de conteúdo
        modified=$(stat -c %y "$file")

        # Escreve no log
        echo "Arquivo: $name | Tamanho: $size bytes | $label: $created | Modificado: $modified" >> "$LOG_FROM"
    fi
done

# Remover arquivos antigos (>3 dias)
echo "===== Remoção de arquivos antigos (>3 dias) =====" >> "$LOG_FROM"
find "$SOURCE_DIR" -type f -ctime +3 -print -delete >> "$LOG_FROM"

# Copiar arquivos recentes (≤3 dias)
echo "===== Cópia de arquivos recentes (≤3 dias) =====" > "$LOG_TO"
find "$SOURCE_DIR" -type f -ctime -3 -print -exec cp {} "$DEST_DIR" \; >> "$LOG_TO"

# Finalização
echo "Processo concluído em $(date)" >> "$LOG_TO"
