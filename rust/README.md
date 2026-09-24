# Skill `rust`: nguồn gốc và cách cập nhật

Skill này lấy từ một nguồn upstream theo giấy phép MIT. Các file trong `references/` được
sao chép nguyên vẹn từng byte. Chỉ `SKILL.md` và `README.md` là viết riêng cho repo này;
phần chỉ mục rule trong `SKILL.md` được sinh từ `SKILL.md` upstream bằng script ở mục 2.

## 1. Nguồn upstream

| Nguồn | Repo | Đường dẫn trong repo | Phiên bản | Commit đã lấy | Ngày lấy | License |
|-------|------|----------------------|-----------|---------------|----------|---------|
| leonardomso | https://github.com/leonardomso/rust-skills | `rules/` | 1.5.1 (Rust 1.96, edition 2024) | `fd2a861ab0406a4ac536a55274d14ea6fd1ca9c9` | 2026-09-24 | `LICENSE-leonardomso` |

### Lấy gì

Toàn bộ 265 file trong `rules/`, giữ nguyên tên, đặt vào `references/`. Các rule link
chéo nhau bằng đường dẫn tương đối cùng thư mục (`](own-borrow-over-clone.md)`), nên giữ
nguyên tên và giữ chung một thư mục là đủ để link không gãy.

Không lấy:

- `SKILL.md`: thay bằng bản viết riêng. Phần "Reference index" trong bản riêng là nội dung
  mục "Quick Reference" của upstream, đổi `rules/` thành `references/`.
- `README.md`, `CHANGELOG.md`, `CONTRIBUTING.md`, `AGENTS.md`, `CLAUDE.md`: tài liệu cho
  người dùng và người đóng góp vào repo upstream. `AGENTS.md` và `CLAUDE.md` chỉ là symlink
  tới `SKILL.md`.
- `checks/`: bộ công cụ biên dịch kiểm tra ví dụ trong rule, chạy ở CI upstream. Không
  phải nội dung skill.

### Khác biệt so với upstream cần nhớ

- `SKILL.md` riêng thêm bảng "Rule application by task" có các dòng cho HTTP handler,
  background worker, request/response body, và mục "Safety". Phần profile Cargo giữ như
  upstream nhưng có ghi chú `panic = "abort"` là lựa chọn, không phải mặc định.
- Upstream cho phép `expect()` khi vi phạm là bug của chương trình (`err-expect-bugs-only`)
  và cấm `unwrap()` trong code production (`err-no-unwrap-prod`). Đây là quy tắc có hiệu
  lực của skill này.

### Lịch sử

Phiên bản 1.0.0 của skill này gộp ba nguồn: Apollo GraphQL `rust-best-practices`,
wshobson `rust-async-patterns`, và ECC `rust-testing`. Phiên bản 2.0.0 thay toàn bộ bằng
leonardomso vì nguồn này bao trùm cả ba, cùng một bộ quy tắc nên không có chỗ mâu thuẫn
phải phân xử, có ví dụ được biên dịch kiểm tra, và cấu trúc một rule một file khớp với
skill `postgres`.

## 2. Quy trình cập nhật từ upstream

Nguyên tắc: không sửa tay file trong `references/`. Mọi thay đổi nội dung đến từ upstream
qua quy trình dưới đây, để lần sau vẫn diff được. Nếu thật sự cần sửa một file, tách phần
sửa thành file mới với tên riêng và ghi vào mục 1.

### Bước 1. Clone nguồn vào thư mục tạm

```bash
TMP=$(mktemp -d)
git clone -q --depth 1 --filter=blob:none --sparse https://github.com/leonardomso/rust-skills.git "$TMP/leo"
git -C "$TMP/leo" sparse-checkout set rules
LEO="$TMP/leo"
echo "leonardomso $(git -C "$LEO" rev-parse HEAD)"
grep -m1 '^  version:' "$LEO/SKILL.md"
```

Ghi lại commit SHA và phiên bản in ra. Nếu SHA trùng với bảng ở mục 1 thì upstream chưa
đổi, dừng ở đây.

### Bước 2. Xem có gì thay đổi

Chạy từ thư mục `skills/rust/`. Lệnh in ra ba loại kết quả: file đã đổi nội dung, file
upstream mới thêm mà skill chưa có, và file skill đang có mà upstream đã xóa.

```bash
cd skills/rust

echo "== file đã đổi nội dung =="
for f in references/*.md; do
  b=$(basename "$f"); [ -f "$LEO/rules/$b" ] && ! cmp -s "$LEO/rules/$b" "$f" && echo "  $b"
done
echo "== file mới ở upstream =="
for f in "$LEO"/rules/*.md; do
  b=$(basename "$f"); [ -f "references/$b" ] || echo "  $b"
done
echo "== file upstream đã xóa =="
for f in references/*.md; do
  b=$(basename "$f"); [ -f "$LEO/rules/$b" ] || echo "  $b"
done
echo "== chỉ mục upstream đã đổi so với phần Reference index của SKILL.md =="
diff <(sed -n '/^## Quick Reference$/,/^## Recommended Cargo.toml Settings$/p' "$LEO/SKILL.md" | grep '^- \[' | sed 's#](rules/#](references/#') \
     <(grep '^- \[' SKILL.md) && echo "  không đổi"
```

Với file đã đổi nội dung, xem diff cụ thể trước khi lấy:

```bash
diff "$LEO/rules/<tên>.md" references/<tên>.md
```

### Bước 3. Áp dụng

```bash
cd skills/rust

# Xóa file upstream đã bỏ, rồi chép đè toàn bộ rule
for f in references/*.md; do
  b=$(basename "$f"); [ -f "$LEO/rules/$b" ] || rm "$f"
done
cp "$LEO"/rules/*.md references/
cp "$LEO/LICENSE" LICENSE-leonardomso

# Sinh lại phần Reference index trong SKILL.md từ chỉ mục upstream.
# Phần index nằm giữa dòng "## Reference index" và dòng "## Recommended Cargo.toml profiles".
python3 - "$LEO/SKILL.md" SKILL.md <<'EOF'
import sys
src=open(sys.argv[1]).read().split('\n')
qr=src[src.index('## Quick Reference')+1:src.index('## Recommended Cargo.toml Settings')]
while qr and qr[-1].strip() in ('','---'): qr.pop()
while qr and qr[0].strip()=='': qr.pop(0)
qr='\n'.join(qr).replace('](rules/','](references/')
dst=open(sys.argv[2]).read().split('\n')
a=dst.index('## Reference index'); b=dst.index('## Recommended Cargo.toml profiles')
out=dst[:a+1]+['']+qr.split('\n')+['']+dst[b:]
open(sys.argv[2],'w').write('\n'.join(out))
EOF
```

Sau đó so bảng "Rule categories by priority" trong `SKILL.md` với bảng cùng tên của
upstream; nếu upstream thêm category hoặc đổi số rule thì sửa tay bảng đó và bảng "Rule
application by task" cho khớp.

### Bước 4. Kiểm tra sau khi cập nhật

```bash
cd skills/rust

# Số file trong references bằng số rule upstream và bằng số dòng chỉ mục
ls references | wc -l; ls "$LEO/rules" | wc -l; grep -c '^- \[' SKILL.md

# Mọi link trong SKILL.md đều trỏ tới file tồn tại
for l in $(grep -o 'references/[a-z0-9-]*\.md' SKILL.md | sort -u); do [ -f "$l" ] || echo "THIẾU: $l"; done

# Mọi file trong references đều được SKILL.md link tới
for f in references/*.md; do grep -q "($f)" SKILL.md || echo "CHƯA LINK: $f"; done

# Link chéo giữa các rule vẫn trỏ tới file tồn tại
for l in $(grep -oh '\]([a-z0-9-]*\.md)' references/*.md | tr -d '[]()' | sort -u); do [ -f "references/$l" ] || echo "GÃY: $l"; done

# Mọi file khớp byte với upstream
for f in references/*.md; do cmp -s "$f" "$LEO/rules/$(basename "$f")" || echo "KHÁC: $f"; done
```

### Bước 5. Ghi lại

- Cập nhật cột "Phiên bản", "Commit đã lấy", "Ngày lấy" trong bảng ở mục 1.
- Nếu tập file lấy hoặc bỏ thay đổi, sửa các danh sách ở mục 1 cho khớp.
- Xóa thư mục tạm: `rm -rf "$TMP"`.
