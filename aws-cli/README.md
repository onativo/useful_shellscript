# AWS Security Group Migration Script

Este script cria um novo Security Group (SG) em uma **nova VPC**, copiando as regras de entrada (**Ingress**) do SG associado a um **Amazon RDS Cluster**. O script:

1. Obtém o Security Group do RDS Cluster especificado.
2. Cria um novo Security Group na VPC de destino.
3. Copia **todas as regras de entrada** (Ingress) do SG original para o novo SG.
4. Mantém as **descrições das regras**.
5. Ignora regras de **Security Groups que pertencem a outra VPC**.
6. Copia regras baseadas em **Publisher Lists**.

## 📌 Requisitos

Antes de rodar o script, certifique-se de:
- Ter o **AWS CLI** instalado e configurado com permissões adequadas.
- Ter **jq** instalado (para manipulação de JSON).
- Possuir permissões para criar Security Groups e modificar regras.

## 🚀 Uso

Execute o script passando **o nome do RDS Cluster** e o **ID da VPC de destino**:

```sh
./create_sg.sh <RDS_CLUSTER_NAME> <NEW_VPC_ID>
```

### 🔹 Exemplo:

```sh
./create_sg.sh my-cluster vpc-67890
```

Isso criará um novo Security Group baseado no SG associado ao **my-cluster**, mas na VPC **vpc-67890**.

## 🔄 Comportamento do Script

- **Regras baseadas em CIDR** 📌✅ → São copiadas para o novo SG mantendo a descrição.
- **Regras baseadas em Publisher List** 📌✅ → São copiadas mantendo a descrição.
- **Regras baseadas em Security Groups** 🔄⚠️ → São **ignoradas** se pertencerem a outra VPC, com um aviso no terminal.
- **Regras de saída (Egress)** ❌🚫 → **Não são copiadas**, pois o AWS cria regras padrão automaticamente.

## 📜 Exemplo de Saída:

```
🔍 Obtendo Security Group do cluster RDS: my-cluster...
🚀 Criando novo Security Group: my-cluster-SG na VPC vpc-67890...
📥 Copiando regras do SG original (sg-123456) para o novo SG (sg-7890)...
🔄 Adicionando regra: PROTO=tcp PORTS=5432 CIDR=10.200.0.0/24 DESC="Acesso ao DB"
⚠️  Ignorando regra que referencia SG sg-234567 (pertence à VPC vpc-11111) DESC="Acesso interno"
✅ Novo Security Group criado com sucesso: sg-7890 (my-cluster-SG) na VPC vpc-67890
```

## 📌 Casos de Uso

Este script pode ser útil nos seguintes cenários:

1. **Migração de VPCs** 🚀 → Quando um banco de dados precisa ser movido para outra VPC, mas as regras de acesso devem ser mantidas.
2. **Clonagem de Ambiente** 🔄 → Criar um ambiente de staging ou dev idêntico ao de produção.
3. **Conformidade e Segurança** 🔒 → Garantir que regras de acesso permaneçam consistentes ao criar novos recursos.
4. **Auditoria e Backup** 🛠️ → Fazer backup da configuração de regras de um SG antes de alterações.

## 🔧 Debugging

Se o script não encontrar regras ou falhar ao criar o SG, tente executar manualmente os comandos:

```sh
aws rds describe-db-clusters --db-cluster-identifier <RDS_CLUSTER_NAME>
aws ec2 describe-security-groups --group-ids <SG_ID>
```

Isso ajudará a verificar se os recursos estão sendo encontrados corretamente.
