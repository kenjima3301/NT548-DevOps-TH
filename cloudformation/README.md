# AWS CloudFormation - Triển khai Hạ tầng Tự động
Dự án triển khai hạ tầng AWS cơ bản (VPC, Public/Private Subnets, EC2) sử dụng CloudFormation Nested Stacks. Mã nguồn được đóng gói và triển khai tự động thông qua script và Amazon S3.

1. Kiến trúc hệ thống
Hệ thống được chia thành 4 template:

    main.yaml (Root Stack): Template chính, điều phối việc gọi các stack con.
    networking.yaml: Cấu hình VPC, Subnets, Route Tables, NAT/Internet Gateway.
    security.yaml: Cấu hình Security Groups.
    compute.yaml: Cấu hình EC2 Instances.
    deploy.sh: Script tự động hóa quy trình đóng gói và triển khai.

2. Yêu cầu trước khi chạy 
Máy tính cài đặt trước:

    AWS CLI v2: Đã cài đặt và cấu hình (aws configure) với quyền Administrator.
    Git Bash (Windows): Sử dụng để chạy script .sh.
    EC2 Key Pair: Đã tạo sẵn trên AWS Console.
    Lưu ý: File private key (.pem) phải được lưu trên máy cá nhân để SSH.

3. Cấu trúc thư mục

    ├── deploy.sh           
    ├── main.yaml           
    ├── networking.yaml     
    ├── security.yaml       
    └── compute.yaml        
4. Hướng dẫn triển khai (Automation)

Bước 1: Tạo S3 Bucket chứa code
Chạy lệnh để tạo bucket:

        aws s3 mb s3://ten-bucket-duy-nhat-cua-ban

Bước 2: Chạy Script Deploy
Mở Git Bash tại thư mục dự án và chạy:

        bash deploy.sh

Bước 3: Nhập thông tin cấu hình

Nhập tên bucket.
Lưu ý: Không nhập thừa khoảng trắng (space).

Tên KeyPair: Nhập tên KeyPair (bỏ phần đuôi .pem)

IP Public

5. Kiểm thử & SSH (Sử dụng SSH Agent Forwarding)
SSH từ Public EC2 sang Private EC2 mà không cần copy file .pem lên server, đảm bảo an toàn bảo mật.

Bước 1: Thêm Key vào SSH Agent (Trên máy cá nhân)
Mở terminal (Git Bash) tại nơi chứa file .pem:

## 1. Kích hoạt ssh-agent
    
    eval "$(ssh-agent -s)"

## 2. Thêm file key vào agent
    
    ssh-add ten-key-cua-ban.pem

## 3. Kiểm tra xem key đã vào chưa (phải hiện ra chuỗi key)
    
    ssh-add -l

Bước 2: SSH vào Public Instance (Bastion Host)
Lấy Public IP của EC2 từ AWS Console hoặc Output của CloudFormation. Chạy lệnh:

    ssh -A ubuntu@<Public-IP-Cua-EC2>

Bước 3: SSH sang Private Instance
Sau khi thành công vào máy Public EC2, SSH thẳng sang máy Private:

    ssh ubuntu@<Private-IP-Cua-EC2>

Nếu có lỗi xác thực chạy lệnh: 

    ssh -o StrictHostKeyChecking=no ubuntu@<Private-IP-Cua-EC2>

Bước 4: Kiểm tra kết nối Internet (NAT Gateway)
Tại máy Private EC2, ping để kiểm tra kết nối ra ngoài Internet.

6. Dọn dẹp (Clean up)
Để xóa toàn bộ tài nguyên và tránh phát sinh chi phí, xóa Stack từ Console hoặc chạy lệnh:

    aws cloudformation delete-stack --stack-name <TEN_STACK_CUA_BAN>