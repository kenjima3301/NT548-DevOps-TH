# AWS CloudFormation - Triển khai Hạ tầng Tự động
Dự án này triển khai hạ tầng AWS cơ bản (VPC, Public/Private Subnets, EC2) sử dụng kỹ thuật CloudFormation Nested Stacks. Toàn bộ mã nguồn được đóng gói và triển khai tự động thông qua script và Amazon S3.

1. Kiến trúc hệ thống
Hệ thống được chia thành 4 template:

    main.yaml (Root Stack): Template chính, điều phối việc gọi các stack con.
    networking.yaml: Cấu hình VPC, Subnets, Route Tables, NAT/Internet Gateway.
    security.yaml: Cấu hình Security Groups.
    compute.yaml: Cấu hình EC2 Instances.
    deploy.sh: Script tự động hóa quy trình đóng gói (package) và triển khai (deploy).

2. Yêu cầu trước khi chạy (Prerequisites)
Để script hoạt động trơn tru, máy tính của bạn cần:

    AWS CLI v2: Đã cài đặt và cấu hình (aws configure) với quyền Administrator.
    Git Bash (Windows): Khuyến nghị sử dụng để chạy script .sh.
    EC2 Key Pair: Đã tạo sẵn trên AWS Console.
    Lưu ý: File private key (.pem) phải được lưu trên máy cá nhân để SSH.

3. Cấu trúc thư mục

    ├── deploy.sh           # Script triển khai tự động
    ├── main.yaml           # Template cha
    ├── networking.yaml     # Template mạng
    ├── security.yaml       # Template bảo mật
    └── compute.yaml        # Template máy chủ
4. Hướng dẫn triển khai (Automation)
Thay vì thao tác thủ công trên Console, chúng ta sẽ sử dụng script.

Bước 1: Tạo S3 Bucket chứa code
Script cần một nơi để upload các template (đã được đóng gói) lên.
Chạy lệnh sau để tạo bucket (Tên phải là duy nhất toàn cầu, viết thường, không dấu):

        aws s3 mb s3://ten-bucket-duy-nhat-cua-ban

Bước 2: Chạy Script Deploy
Mở Git Bash tại thư mục dự án và chạy:

        bash deploy.sh

Bước 3: Nhập thông tin cấu hình
Script sẽ hỏi các thông tin đầu vào. Hãy nhập chính xác:

Tên S3 Bucket: Nhập tên bucket bạn vừa tạo ở Bước 1.
Lưu ý: Không nhập thừa khoảng trắng (space).

Tên KeyPair: Nhập tên KeyPair trên AWS.

⚠️ Quan trọng: Chỉ nhập tên (VD: keypair), KHÔNG nhập đuôi .pem.

IP Public: Nhấn Enter để tự động lấy IP hiện tại của bạn.

Sau đó, script sẽ tự động upload file lên S3 và tạo Stack trên CloudFormation. Quá trình này mất khoảng 5-10 phút.

5. Kiểm thử & SSH (Sử dụng SSH Agent Forwarding)
Phương pháp này cho phép SSH từ Public EC2 sang Private EC2 mà không cần copy file .pem lên server, đảm bảo an toàn bảo mật.
Bước 1: Thêm Key vào SSH Agent (Trên máy cá nhân)
Mở terminal (Git Bash) tại nơi chứa file .pem:

# 1. Kích hoạt ssh-agent
    
    eval "$(ssh-agent -s)"

# 2. Thêm file key vào agent
    
    ssh-add ten-key-cua-ban.pem

# 3. Kiểm tra xem key đã vào chưa (phải hiện ra chuỗi key)
    
    ssh-add -l

Bước 2: SSH vào Public Instance (Bastion Host)
Lấy Public IP của EC2 từ AWS Console hoặc Output của CloudFormation. Sử dụng tham số -A để bật tính năng Forwarding:

    ssh -A ubuntu@<Public-IP-Cua-EC2>

Bước 3: SSH sang Private Instance
Sau khi đã đứng ở trong máy Public EC2, bạn có thể SSH thẳng sang máy Private (dùng Private IP):

    ssh ubuntu@<Private-IP-Cua-EC2>

Bước 4: Kiểm tra kết nối Internet (NAT Gateway)
Tại máy Private EC2, chạy lệnh ping để kiểm tra kết nối ra ngoài Internet:

    ping google.com

6. Dọn dẹp (Clean up)
Để xóa toàn bộ tài nguyên và tránh phát sinh chi phí, bạn có thể xóa Stack từ Console hoặc chạy lệnh:

    aws cloudformation delete-stack --stack-name <TEN_STACK_CUA_BAN>