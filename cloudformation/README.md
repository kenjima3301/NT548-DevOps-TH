# AWS Cloudformation
# AWS CloudFormation - Triển khai Hạ tầng 
Dự án này triển khai hạ tầng AWS cơ bản (VPC, Public/Private Subnets, EC2) sử dụng kỹ thuật CloudFormation Nested Stacks. Toàn bộ mã nguồn được lưu trữ và triển khai trực tiếp từ Amazon S3.

1. Kiến trúc hệ thống
Hệ thống được chia thành 4 template:

main.yaml (Root Stack): Template chính, điều phối việc gọi các stack con.

networking.yaml: Cấu hình VPC, Subnets, Route Tables, NAT/Internet Gateway.

security.yaml: Cấu hình Security Groups.

compute.yaml: Cấu hình EC2 Instances.

2. Yêu cầu trước khi chạy (Prerequisites)

Tài khoản AWS có quyền Administrator.

EC2 Key Pair: Đã tạo sẵn trên AWS và file private key (.pem) đã được lưu trên máy cá nhân.

S3 Bucket: Đã tạo sẵn một Bucket để chứa template.

3. Cấu trúc thư mục
.
├── main.yaml
├── networking.yaml
├── security.yaml
└── compute.yaml

4. Hướng dẫn triển khai 

Bước 1: Upload Template lên S3
Truy cập S3 Console.

Upload tất cả 4 file (main.yaml, networking.yaml, security.yaml, compute.yaml) lên Bucket.

Copy Object URL của file main.yaml (Dùng cho Bước 2).

Copy URL của thư mục Bucket (Dùng cho tham số S3BucketURL ở Bước 3).

Bước 2: Khởi tạo Stack
Truy cập CloudFormation Console -> Create stack -> With new resources (standard).

Chọn Amazon S3 URL -> Dán URL của file main.yaml.

Nhấn Next.

Bước 3: Điền tham số (Configure parameters)
Stack name: Lab1-CloudFormation.

KeyName: Chọn Key Pair tương ứng với file .pem bạn đang giữ.

MyPublicIP: Điền IP Public của máy bạn + /32 (Ví dụ: 123.45.67.89/32).

S3BucketURL: Điền đường dẫn Bucket chứa file (Lưu ý: Không có dấu / ở cuối).

Bước 4: Deploy
Nhấn Next qua các bước.

Tích chọn "I acknowledge that AWS CloudFormation might create IAM resources...".

Nhấn Submit và đợi trạng thái CREATE_COMPLETE.

5. Kiểm thử & SSH (Sử dụng SSH Agent Forwarding)
Phương pháp này cho phép SSH từ Public EC2 sang Private EC2 mà không cần copy file .pem lên server, đảm bảo an toàn bảo mật.

Bước 1: Thêm Key vào SSH Agent (Trên máy cá nhân)
Mở terminal (Git Bash, PowerShell hoặc Terminal Linux/Mac) tại thư mục chứa file key .pem:

# 1. Kích hoạt ssh-agent (nếu chưa chạy)
eval "$(ssh-agent -s)"

# 2. Thêm file key vào agent
ssh-add ten-key-cua-ban.pem

# 3. Kiểm tra xem key đã vào chưa
ssh-add -l

Bước 2: SSH vào Public Instance (Bastion Host)
Sử dụng tham số -A để bật tính năng Forwarding:

ssh -A ubuntu@<Public-IP-Cua-EC2>

Bước 3: SSH sang Private Instance
Sau khi đã đứng ở trong máy Public EC2, bạn có thể SSH thẳng sang máy Private mà không cần file key (Agent sẽ tự chuyển tiếp xác thực):

ssh ubuntu@<Private-IP-Cua-EC2>

Bước 4: Kiểm tra kết nối Internet (NAT Gateway)
Tại máy Private EC2, chạy lệnh ping để kiểm tra:

    ping google.com

Kết quả mong đợi: Có phản hồi (reply), chứng tỏ kết nối thành công.

6. Dọn dẹp (Clean up)
Vào CloudFormation, chọn Stack cha (Lab1-CloudFormation) -> Delete để xóa toàn bộ tài nguyên.