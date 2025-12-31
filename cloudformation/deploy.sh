STACK_NAME="Lab1-NestedStack"
REGION="ap-southeast-1"  

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' 

echo -e "${GREEN}==============================================${NC}"
echo -e "${GREEN}   SCRIPT TỰ ĐỘNG DEPLOY AWS CLOUDFORMATION   ${NC}"
echo -e "${GREEN}   Region: $REGION                            ${NC}"
echo -e "${GREEN}==============================================${NC}"

echo -e "${YELLOW}[INPUT] Nhập tên S3 Bucket chứa code (Bắt buộc):${NC}"
read BUCKET_NAME

if [ -z "$BUCKET_NAME" ]; then
  echo -e "${RED}Lỗi: Bạn chưa nhập tên Bucket!${NC}"
  exit 1
fi

echo -e "${YELLOW}[INPUT] Nhập tên KeyPair (VD: vockey):${NC}"
read KEY_NAME

if [ -z "$KEY_NAME" ]; then
  echo -e "${RED}Lỗi: Bạn chưa nhập KeyPair!${NC}"
  exit 1
fi

CURRENT_IP=$(curl -s http://checkip.amazonaws.com)
echo -e "${YELLOW}[INPUT] IP Public hiện tại của bạn là: $CURRENT_IP${NC}"
echo -e "Nhấn [ENTER] để dùng IP này, hoặc nhập IP khác:"
read INPUT_IP

if [ -z "$INPUT_IP" ]; then
  MY_IP="$CURRENT_IP/32"
else
  MY_IP="$INPUT_IP/32"
fi

echo "----------------------------------------------------"
echo -e "${GREEN}[BƯỚC 1] Packaging... (Upload file lên S3)${NC}"

# Upload file local -> S3 và tạo ra file packaged-template.yaml
aws cloudformation package \
    --template-file main.yaml \
    --s3-bucket "$BUCKET_NAME" \
    --output-template-file packaged-template.yaml \
    --region $REGION

if [ $? -ne 0 ]; then
  echo -e "${RED}❌ Lỗi: Không thể upload lên S3. Kiểm tra lại tên Bucket hoặc quyền AWS CLI.${NC}"
  exit 1
fi

echo "----------------------------------------------------"
echo -e "${GREEN}[BƯỚC 2] Deploying... (Tạo Stack trên AWS)${NC}"

aws cloudformation deploy \
    --template-file packaged-template.yaml \
    --stack-name "$STACK_NAME" \
    --capabilities CAPABILITY_IAM CAPABILITY_AUTO_EXPAND \
    --parameter-overrides \
        KeyName="$KEY_NAME" \
        MyPublicIP="$MY_IP" \
    --region $REGION

if [ $? -eq 0 ]; then
    echo "----------------------------------------------------"
    echo -e "${GREEN}✅ TRIỂN KHAI THÀNH CÔNG!${NC}"
    echo ""
    echo -e "${YELLOW}👇 Dưới đây là thông tin kết nối (Outputs):${NC}"
    
    aws cloudformation describe-stacks \
        --stack-name "$STACK_NAME" \
        --region $REGION \
        --query "Stacks[0].Outputs" \
        --output table
else
    echo -e "${RED}❌ Triển khai thất bại!${NC}"
    exit 1
fi