#!/bin/bash

# Verifica se os argumentos foram passados corretamente
if [ $# -ne 2 ]; then
    echo "Uso: $0 <RDS_CLUSTER_NAME> <NEW_VPC_ID>"
    exit 1
fi

# Definição de variáveis
RDS_CLUSTER_NAME="$1"
NEW_VPC_ID="$2"

echo "🔍 Obtendo Security Group do cluster RDS: $RDS_CLUSTER_NAME..."
SG_ID=$(aws rds describe-db-clusters --db-cluster-identifier "$RDS_CLUSTER_NAME" --query "DBClusters[0].VpcSecurityGroups[0].VpcSecurityGroupId" --output text)

if [ -z "$SG_ID" ] || [ "$SG_ID" == "None" ]; then
    echo "❌ Erro: Nenhum Security Group encontrado para o cluster $RDS_CLUSTER_NAME."
    exit 1
fi

# Criando nome e descrição do novo SG
NEW_SG_NAME="${RDS_CLUSTER_NAME}-SG"
DESCRIPTION="Security group for ${RDS_CLUSTER_NAME}. Created at: $(date +'%d-%m-%Y %H:%M:%S')"

echo "🚀 Criando novo Security Group: $NEW_SG_NAME na VPC $NEW_VPC_ID..."
NEW_SG=$(aws ec2 create-security-group --group-name "$NEW_SG_NAME" --description "$DESCRIPTION" --vpc-id "$NEW_VPC_ID" --query "GroupId" --output text)

if [ -z "$NEW_SG" ]; then
    echo "❌ Erro: Falha ao criar o novo Security Group."
    exit 1
fi

# Adicionando tag Name ao novo SG
aws ec2 create-tags --resources "$NEW_SG" --tags Key=Name,Value="$NEW_SG_NAME"

# Pegando regras do Security Group original
echo "📥 Copiando regras do SG original ($SG_ID) para o novo SG ($NEW_SG)..."

# Processar regras de entrada (Ingress)
INGRESS_RULES=$(aws ec2 describe-security-groups --group-ids "$SG_ID" --query "SecurityGroups[0].IpPermissions" --output json)

echo "$INGRESS_RULES" | jq -c '.[]' | while read -r rule; do
    PROTOCOL=$(echo "$rule" | jq -r '.IpProtocol')
    FROM_PORT=$(echo "$rule" | jq -r '.FromPort // empty')
    TO_PORT=$(echo "$rule" | jq -r '.ToPort // empty')

    # Copia regras baseadas em IPs e mantém a descrição
    echo "$rule" | jq -c '.IpRanges[]?' | while read -r ip_rule; do
        CIDR=$(echo "$ip_rule" | jq -r '.CidrIp')
        DESC=$(echo "$ip_rule" | jq -r '.Description // empty')

        if [[ -n "$CIDR" ]]; then
            echo "🔄 Adicionando regra: PROTO=$PROTOCOL PORTS=$FROM_PORT-$TO_PORT CIDR=$CIDR DESC=\"$DESC\""
            aws ec2 authorize-security-group-ingress \
                --group-id "$NEW_SG" \
                --ip-permissions "[{\"IpProtocol\":\"$PROTOCOL\",\"FromPort\":$FROM_PORT,\"ToPort\":$TO_PORT,\"IpRanges\":[{\"CidrIp\":\"$CIDR\",\"Description\":\"$DESC\"}]}]" \
                --output text > /dev/null 2>&1 || true
        fi
    done

    # Copia regras baseadas em Publisher List e mantém a descrição
    echo "$rule" | jq -c '.PrefixListIds[]?' | while read -r prefix_rule; do
        PREFIX_LIST_ID=$(echo "$prefix_rule" | jq -r '.PrefixListId')
        DESC=$(echo "$prefix_rule" | jq -r '.Description // empty')

        if [[ -n "$PREFIX_LIST_ID" ]]; then
            echo "🔄 Adicionando regra com Publisher List: PROTO=$PROTOCOL PORTS=$FROM_PORT-$TO_PORT PREFIX_LIST=$PREFIX_LIST_ID DESC=\"$DESC\""
            aws ec2 authorize-security-group-ingress \
                --group-id "$NEW_SG" \
                --ip-permissions "[{\"IpProtocol\":\"$PROTOCOL\",\"FromPort\":$FROM_PORT,\"ToPort\":$TO_PORT,\"PrefixListIds\":[{\"PrefixListId\":\"$PREFIX_LIST_ID\",\"Description\":\"$DESC\"}]}]" \
                --output text > /dev/null 2>&1 || true
        fi
    done

    # Ignora regras de SG de outra VPC, mas avisa no terminal
    echo "$rule" | jq -c '.UserIdGroupPairs[]?' | while read -r sg_rule; do
        GROUP_ID=$(echo "$sg_rule" | jq -r '.GroupId')
        DESC=$(echo "$sg_rule" | jq -r '.Description // empty')

        if [[ -n "$GROUP_ID" ]]; then
            GROUP_VPC=$(aws ec2 describe-security-groups --group-ids "$GROUP_ID" --query "SecurityGroups[0].VpcId" --output text 2>/dev/null)

            if [[ "$GROUP_VPC" != "$NEW_VPC_ID" ]]; then
                echo "⚠️  Ignorando regra que referencia SG $GROUP_ID (pertence à VPC $GROUP_VPC) DESC=\"$DESC\""
            fi
        fi
    done
done

echo "✅ Novo Security Group criado com sucesso: $NEW_SG ($NEW_SG_NAME) na VPC $NEW_VPC_ID"
