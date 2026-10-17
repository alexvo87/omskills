# Skill `rust-unsafe`: nguồn gốc và cách cập nhật

Skill này lấy 47 rule về unsafe Rust và FFI từ một nguồn upstream, rồi chuyển ví dụ
sang cú pháp Rust 2024 bằng script `patch.sh`. Khác với `rust`, `postgres`, `mariadb`,
các file trong `references/` KHÔNG giống upstream từng byte: chúng bằng upstream cộng
đúng những thay đổi mà `patch.sh` tạo ra. Chỉ `SKILL.md`, `README.md`, `patch.sh` là
viết riêng cho repo này.

## 1. Nguồn upstream

| Nguồn | Repo | Đường dẫn trong repo | Phiên bản | Commit đã lấy | Ngày lấy | License |
|-------|------|----------------------|-----------|---------------|----------|---------|
| actionbook | https://github.com/actionbook/rust-skills | `skills/unsafe-checker/rules/` | plugin 2.0.9, unsafe-checker 1.0.0 | `5c40d3ad785193231b7d0dbfb8e1eb447e5edd94` | 2026-10-17 | xem mục "Giấy phép" |

actionbook dịch 47 rule này sang tiếng Anh từ nhóm `P.UNS.*` và `G.UNS.*` của
https://github.com/Rust-Coding-Guidelines/rust-coding-guidelines-zh (MIT). Frontmatter
`original_id` trong mỗi file trỏ về id gốc.

### Lấy gì

47 file trong `rules/` có tên không bắt đầu bằng `_` (`ffi-*`, `general-*`, `io-*`,
`mem-*`, `ptr-*`, `safety-*`, `union-*`), giữ nguyên tên, đặt vào `references/`. Các rule
tham chiếu nhau bằng id dạng text (`safety-04`), không phải link Markdown, nên đổi thư
mục không gãy link.

Không lấy:

- `SKILL.md`, `AGENTS.md`, `metadata.json`: thay bằng `SKILL.md` viết riêng. Bảng rule
  và bảng Clippy trong `SKILL.md` riêng lấy từ `AGENTS.md` upstream.
- `rules/_sections.md`, `rules/_template.md`: tài liệu cho người đóng góp upstream.
- `checklists/`, `examples/`: nội dung tổng hợp lại từ các rule, viết theo cú pháp 2021.
- Mọi thứ khác của plugin actionbook (hook, agent, command, 37 skill còn lại): không
  phải rule, và phụ thuộc runtime của plugin.

### Giấy phép

Repo actionbook không có file LICENSE. `metadata.json` và `.claude-plugin/plugin.json`
ghi `"license": "MIT"`, README của họ trỏ tới một file LICENSE không tồn tại. Repo này
chấp nhận tuyên bố MIT trong metadata làm tuyên bố giấy phép của bản dịch, giống cách
`agentkit-lite` ghi nhận upstream không có file license. File
`LICENSE-rust-coding-guidelines-zh` là giấy phép MIT của nguồn gốc tiếng Trung, lấy từ
`https://raw.githubusercontent.com/Rust-Coding-Guidelines/rust-coding-guidelines-zh/main/LICENSE`.
Nếu actionbook thêm file LICENSE, chép về thành `LICENSE-actionbook` và sửa mục này.

### Khác biệt so với upstream: `patch.sh`

Upstream viết ví dụ theo Rust 2021. Skill `rust` của repo này nhắm edition 2024 và có hai
rule (`unsafe-extern-block`, `unsafe-no-mangle-unsafe`) bắt buộc cú pháp mới, nên ví dụ
ở đây được chuyển sang 2024 để hai skill không nói ngược nhau. `patch.sh` làm bốn việc,
mỗi việc là thay thế chuỗi neo với số lần phải khớp chính xác, sai thì không ghi file nào:

1. `extern "C" {` thành `unsafe extern "C" {` (34 chỗ, 18 file). Edition 2024 bắt buộc
   khối extern phải là `unsafe extern`.
2. `#[no_mangle]` thành `#[unsafe(no_mangle)]` (20 chỗ, 4 file, gồm cả một chỗ trong
   phần tóm tắt của `ffi-10`). Edition 2024 coi đây là unsafe attribute.
3. `rand::thread_rng().gen()` thành `rand::rng().random()` (1 chỗ, `mem-04`). `gen` là
   từ khóa dành riêng trong 2024; tên mới là API của rand 0.9.
4. Bọc thao tác unsafe bên trong thân `unsafe fn` vào khối `unsafe { }` kèm chú thích
   SAFETY (15 chỗ trong `ffi-09`, `ffi-14`, `general-03`, `safety-02`, `safety-06`,
   `safety-07`, `safety-11`). Lint `unsafe_op_in_unsafe_fn` cảnh báo mặc định từ 2024.
   Ví dụ xấu cũng được bọc để điểm xấu của ví dụ vẫn là điều rule muốn nói, không phải
   lỗi cú pháp.

Những gì KHÔNG đổi, dù không phải phong cách mới nhất: `std::os::raw::*` (vẫn hợp lệ,
`core::ffi::*` chỉ là lựa chọn mới hơn), các mốc "Rust 1.63+" trong `io-01`, và các ví
dụ xấu dùng `static mut` hay `mem::zeroed()` vì chúng đang minh họa điều cần tránh.

Ví dụ trong rule là đoạn minh họa, không biên dịch được độc lập (dùng kiểu không khai báo
như `MyVec`, `Data`). Bước 4 dưới đây chỉ kiểm tra chúng không còn lỗi riêng của edition
2024, không kiểm tra chúng biên dịch được.

## 2. Quy trình cập nhật từ upstream

Nguyên tắc: không sửa tay file trong `references/`. Mọi khác biệt với upstream đến từ
`patch.sh`. Nếu cần thêm một thay đổi, thêm vào `patch.sh` kèm số lần khớp và ghi vào mục 1.

### Bước 1. Clone nguồn vào thư mục tạm

```bash
TMP=$(mktemp -d)
git clone -q --depth 1 --filter=blob:none --sparse https://github.com/actionbook/rust-skills.git "$TMP/ab"
git -C "$TMP/ab" sparse-checkout set skills/unsafe-checker
AB="$TMP/ab/skills/unsafe-checker"
echo "actionbook $(git -C "$TMP/ab" rev-parse HEAD)"
cat "$TMP/ab/VERSION"; grep '"version"' "$AB/metadata.json"
ls "$TMP/ab"/LICENSE* 2>/dev/null || echo "upstream vẫn chưa có file LICENSE"
```

Nếu SHA trùng với bảng ở mục 1 thì upstream chưa đổi, dừng ở đây.

### Bước 2. Xem có gì thay đổi

Chạy `patch.sh` lên bản upstream mới trong thư mục tạm, rồi diff với `references/`:

```bash
cd skills/rust-unsafe
mkdir "$TMP/new"; cp "$AB"/rules/[a-z]*-[0-9]*.md "$TMP/new/"
./patch.sh "$TMP/new"        # thất bại nếu upstream đổi chỗ có neo: đọc lỗi, sửa patch.sh
echo "== file đã đổi =="; for f in references/*.md; do b=$(basename "$f"); [ -f "$TMP/new/$b" ] && ! cmp -s "$TMP/new/$b" "$f" && echo "  $b"; done
echo "== file mới =="; for f in "$TMP"/new/*.md; do b=$(basename "$f"); [ -f "references/$b" ] || echo "  $b"; done
echo "== file đã xóa =="; for f in references/*.md; do b=$(basename "$f"); [ -f "$TMP/new/$b" ] || echo "  $b"; done
```

Với file mới, kiểm tra cú pháp 2021 còn sót mà `patch.sh` chưa biết (xem bước 4) và bổ
sung neo vào `patch.sh` nếu cần.

### Bước 3. Áp dụng

```bash
cd skills/rust-unsafe
rm references/*.md; cp "$TMP"/new/*.md references/
```

Rồi sửa tay `SKILL.md`: bảng "Rule groups by priority", mục "Reference index" (một dòng
mỗi rule, tóm tắt lấy từ mục "## Summary" của file), bảng Clippy (từ `AGENTS.md` upstream).

### Bước 4. Kiểm tra sau khi cập nhật

```bash
cd skills/rust-unsafe

# Số file bằng số rule upstream và bằng số dòng chỉ mục
ls references | wc -l; ls "$AB"/rules/[a-z]*-[0-9]*.md | wc -l; grep -c '^- \[' SKILL.md

# Mọi link trong SKILL.md trỏ tới file tồn tại, và mọi file đều được link
for l in $(grep -o 'references/[a-z0-9-]*\.md' SKILL.md | sort -u); do [ -f "$l" ] || echo "THIẾU: $l"; done
for f in references/*.md; do grep -q "($f)" SKILL.md || echo "CHƯA LINK: $f"; done

# Không còn cú pháp 2021 mà patch.sh xử lý
grep -l '#\[no_mangle\]\|\.gen()' references/*.md; grep -n '^extern "C" {\|[^e] extern "C" {' references/*.md

# Mỗi block ```rust không còn lỗi riêng của edition 2024 (cần rustc >= 1.85).
# Chỉ giữ các chẩn đoán về edition; lỗi "cannot find type" của đoạn minh họa bị bỏ qua.
python3 - references <<'PYCHECK'
import os, re, subprocess, sys, tempfile
root = sys.argv[1]
NEEDLES = ("extern blocks must be unsafe", "unsafe attribute used without unsafe",
           "reserved keyword `gen`", "is unsafe and requires unsafe block",
           "reference to mutable static")
blocks = hits = 0
for f in sorted(os.listdir(root)):
    if not f.endswith(".md"): continue
    text = open(os.path.join(root, f), encoding="utf-8").read()
    for i, code in enumerate(re.findall(r"```rust[^\n]*\n(.*?)```", text, re.S), 1):
        blocks += 1
        with tempfile.TemporaryDirectory() as d:
            src = os.path.join(d, "b.rs"); open(src, "w").write(code)
            r = subprocess.run(["rustc", "--edition", "2024", "--crate-type", "lib",
                                "--emit=metadata", "-o", os.path.join(d, "out"),
                                "-W", "unsafe_op_in_unsafe_fn", src],
                               capture_output=True, text=True)
        found = sorted({n for n in NEEDLES if n in r.stderr})
        if found:
            hits += 1; print(f"{f} block {i}: {', '.join(found)}")
print(f"{blocks} blocks checked, {hits} with edition-2024 problems")
PYCHECK

# references/ bằng upstream cộng patch.sh, không có sửa tay
for f in references/*.md; do cmp -s "$f" "$TMP/new/$(basename "$f")" || echo "KHÁC: $f"; done
```

Giới hạn của bước kiểm tra rustc: lint `unsafe_op_in_unsafe_fn` chỉ chạy khi đoạn code
qua được bước phân giải tên, nên với đoạn dùng kiểu chưa khai báo nó không phát hiện
được; mục 4 của `patch.sh` được rà bằng tay (grep `unsafe fn` rồi đọc thân hàm).

### Bước 5. Ghi lại

- Cập nhật cột "Phiên bản", "Commit đã lấy", "Ngày lấy" trong bảng ở mục 1.
- Nếu `patch.sh` thêm hay bớt neo, sửa danh sách bốn việc và số lần khớp ở mục 1.
- Xóa thư mục tạm: `rm -rf "$TMP"`.
