# AWS Lab - Terraform Modular Design

Project này sử dụng Terraform để dựng một VPC cơ bản trên AWS theo cấu trúc Module. Mục đích chính là thực hành chia tách code và quản lý networking giữa Public và Private subnet.

## Mô hình kiến trúc

* **VPC & Network:**
    * 1 VPC (`10.0.0.0/16`) tại Singapore (`ap-southeast-1`).
    * **Public Subnet:** Chứa Public EC2 và NAT Gateway.
    * **Private Subnet:** Chứa Private EC2, kết nối Internet thông qua NAT Gateway.
* **Compute:**
    * **Public EC2:** Có IP Public, dùng làm cổng để SSH vào hệ thống.
    * **Private EC2:** Không có IP Public, chỉ nhận kết nối SSH từ con Public EC2.
    * **Security Groups:** Cấu hình chỉ cho phép IP của máy admin SSH vào Public EC2.

## Cấu trúc thư mục

Dự án được tổ chức tách biệt giữa source code (modules) và môi trường chạy (envs):

```text
terraform/
├── modules/
│   ├── network/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   ├── ec2/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   └── outputs.tf
│   └── my-aws-key.pub
├── envs/
│   └── dev/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── terraform.tfvars
└── README.md
```

## Hướng dẫn triển khai (Quick Start)

### 1. Yêu cầu tiên quyết (Prerequisites)
* [Terraform](https://www.terraform.io/downloads) (v1.0+)
* AWS CLI (đã cấu hình `aws configure`)
* File Public Key (`my-aws-key.pub`) đặt tại thư mục `modules/`.

### 2. Khởi tạo & Lên kế hoạch
Di chuyển vào thư mục môi trường Dev:

```bash
cd envs/dev
```

Khởi tạo Terraform và tải các modules:

```bash
terraform init
```

Kiểm tra lỗi cú pháp:

```bash
terraform validate
```

Xem trước kế hoạch triển khai:

```bash
terraform plan
```

### 3. Triển khai hạ tầng (Apply)
Thực thi lệnh sau để tạo tài nguyên trên AWS:

```bash
terraform apply --auto-approve
```

### 4. Truy cập hệ thống (SSH)
Sau khi triển khai thành công, Terraform sẽ xuất ra (Output) các lệnh SSH mẫu.

**- Truy cập Public EC2**
```bash
ssh -i my-aws-key.pem ubuntu@<PUBLIC_IP>
```

**- Truy cập Private EC2 (Jump)**
Sử dụng tính năng ProxyJump để vào thẳng Private Server:
```bash
eval "$(ssh-agent -s)"
ssh-add my-aws-key.pem          # Nạp private key
ssh -J ubuntu@<PUBLIC_IP> -i my-aws-key.pem ubuntu@<PRIVATE_IP>
```
*(Lưu ý: Thay thế `<PUBLIC_IP>` và `<PRIVATE_IP>` bằng địa chỉ thực tế trong Output)*

## Dọn dẹp tài nguyên (Destroy)
Để xóa toàn bộ hạ tầng và tránh phát sinh chi phí:

```bash
terraform destroy --auto-approve
```

## Thông tin cấu hình (Variables)

Các thông số chính có thể tùy chỉnh trong `envs/dev/terraform.tfvars`:

| Tên biến | Mô tả | Giá trị mặc định |
|---|---|---|
| `region` | AWS Region | `ap-southeast-1` |
| `instance_type` | Loại EC2 | `t3.micro` |
| `my_ip` | IP Admin (Whitelist) | `Your-IP/32` |
| `vpc_cidr` | Dải mạng VPC | `10.0.0.0/16` |

---
