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

# Listar todos os itens (arquivos + pastas) recursivamente
find "$SOURCE_DIR" -mindepth 1 | while read -r item; do
    name=$(basename "$item")
    size=$(stat -c%s "$item" 2>/dev/null || echo 0)

    # Tenta pegar a data de criação (birth time)
    created=$(stat -c %w "$item" 2>/dev/null)

    # Se não existir, usa a última alteração de metadados
    if [ "$created" = "-" ] || [ -z "$created" ]; then
        created=$(stat -c %z "$item" 2>/dev/null)
        label="Alterado"
    else
        label="Criado"
    fi

    # Última modificação
    modified=$(stat -c %y "$item" 2>/dev/null)

    # Tipo de item
    if [ -d "$item" ]; then
        type_item="Pasta"
    elif [ -f "$item" ]; then
        type_item="Arquivo"
    else
        type_item="Outro"
    fi

    echo "$type_item: $name | Tamanho: $size bytes | $label: $created | Modificado: $modified" >> "$LOG_FROM"
done

# ===== Remoção de itens antigos (>3 dias) =====
echo "===== Remoção de itens antigos (>3 dias) =====" >> "$LOG_FROM"
# Remove arquivos e pastas recursivamente
find "$SOURCE_DIR" -mindepth 1 -ctime +3 -exec rm -rf {} \; -print >> "$LOG_FROM"

# ===== Cópia de itens recentes (≤3 dias) =====
echo "===== Cópia de itens recentes (≤3 dias) =====" > "$LOG_TO"
find "$SOURCE_DIR" -mindepth 1 -ctime -3 -exec cp -r --parents {} "$DEST_DIR" \; -print >> "$LOG_TO"

# Finalização
echo "Processo concluído em $(date)" >> "$LOG_TO"
