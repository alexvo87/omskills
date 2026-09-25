# Skill `mariadb`: nguồn gốc và cách cập nhật

Skill này gộp hai skill upstream theo giấy phép MIT thành một skill MariaDB/MySQL InnoDB
trung lập, không gắn với nhà cung cấp nào. Các file trong `references/` được sao chép nguyên
vẹn từng byte, trừ hai file đã cắt đoạn quảng cáo nhà cung cấp bằng script (xem "Khác biệt
so với upstream"). Chỉ `SKILL.md` và `README.md` là viết riêng cho repo này.

## 1. Hai nguồn upstream

| Nguồn | Repo | Đường dẫn trong repo | Phiên bản | Commit đã lấy | Ngày lấy | License |
|-------|------|----------------------|-----------|---------------|----------|---------|
| MariaDB | https://github.com/mariadb/skills | `mariadb-query-optimization/SKILL.md` | Last updated 2026-06-05 (baseline 11.8 LTS) | `86623494f8051e766c973d35c1f07368c3b4c267` | 2026-09-25 | `LICENSE-mariadb` |
| PlanetScale | https://github.com/planetscale/database-skills | `skills/mysql/` | 1.0.0 | `73b20b7eb64716d8c7100c054f0677c0c6e77e30` | 2026-09-25 | `LICENSE-planetscale` |

### Lấy gì từ MariaDB

Repo upstream không có thư mục `references/`; mỗi skill là một file `SKILL.md` duy nhất.
Lấy nguyên file `mariadb-query-optimization/SKILL.md`, đặt vào
`references/mariadb-query-optimization.md`. Frontmatter `name`/`description` của upstream
vẫn còn trong file; agent chỉ đọc frontmatter của `SKILL.md` ngoài cùng nên không ảnh hưởng.
Các link nội bộ dạng `#functions-on-indexed-columns` vẫn đúng vì file giữ nguyên nội dung.

Không lấy:

- `mariadb-features`, `mysql-to-mariadb`, `oracle-to-mariadb`, `mariadb-replication-and-ha`,
  `mariadb-system-versioned-tables`, `mariadb-vector`, `mariadb-mcp`: ngoài phạm vi tối ưu
  truy vấn và thiết kế schema. Có thể cân nhắc `mysql-to-mariadb` cho lần sau nếu cần bảng
  khác biệt đầy đủ hơn mục "MariaDB differences" trong `SKILL.md`.
- `README.md`, `CLAUDE.md`, `.gitignore`: tài liệu cho người đóng góp vào repo upstream.

### Lấy gì từ PlanetScale

Toàn bộ 18 file trong `skills/mysql/references/`, đổi tên thêm tiền tố `mysql-`. Tiền tố
đánh dấu file viết theo MySQL 8: agent phải tra bảng "MariaDB differences" trong `SKILL.md`
trước khi dùng cú pháp trong đó trên MariaDB.

| File upstream | File trong skill |
|---------------|------------------|
| `character-sets.md` | `mysql-character-sets.md` |
| `composite-indexes.md` | `mysql-composite-indexes.md` |
| `connection-management.md` | `mysql-connection-management.md` |
| `covering-indexes.md` | `mysql-covering-indexes.md` |
| `data-types.md` | `mysql-data-types.md` |
| `deadlocks.md` | `mysql-deadlocks.md` |
| `explain-analysis.md` | `mysql-explain-analysis.md` |
| `fulltext-indexes.md` | `mysql-fulltext-indexes.md` |
| `index-maintenance.md` | `mysql-index-maintenance.md` |
| `isolation-levels.md` | `mysql-isolation-levels.md` |
| `json-column-patterns.md` | `mysql-json-column-patterns.md` |
| `n-plus-one.md` | `mysql-n-plus-one.md` |
| `online-ddl.md` | `mysql-online-ddl.md` |
| `partitioning.md` | `mysql-partitioning.md` |
| `primary-keys.md` | `mysql-primary-keys.md` |
| `query-optimization-pitfalls.md` | `mysql-query-optimization-pitfalls.md` |
| `replication-lag.md` | `mysql-replication-lag.md` |
| `row-locking-gotchas.md` | `mysql-row-locking-gotchas.md` |

Không lấy:

- `SKILL.md`: có đoạn khuyến nghị hosting của PlanetScale và link tuyệt đối tới
  `raw.githubusercontent.com`. Thay bằng bản viết riêng.

### Khác biệt so với upstream cần nhớ

- Hai file `mysql-connection-management.md` và `mysql-online-ddl.md` không khớp byte với
  upstream: đã cắt mục "Vitess / PlanetScale Note", mục "PlanetScale Users", và cụm
  "or **PlanetScale connection pooling**" trong mục "When to Use a Proxy". Việc cắt làm bằng
  script ở bước 3 để lần cập nhật sau lặp lại được; bước 4 so byte với bản upstream đã cắt
  cùng cách. Script còn chuẩn hoá file kết thúc bằng đúng một newline, nên
  `mysql-isolation-levels.md` và `mysql-json-column-patterns.md` ngắn hơn upstream một dòng
  trống cuối file. 14 file `mysql-*` còn lại và file MariaDB khớp byte.
- File MariaDB viết cho baseline 11.8 LTS. Với server 10.3, nhiều mẹo không áp dụng
  (hàm sargable 11.1+, `IGNORED` 10.6+, hint 12.0+, histogram mặc định bật 10.4+).
  `SKILL.md` có bảng phiên bản tối thiểu và mục riêng cho 10.3.
- Hai chỗ file MariaDB nói rộng hơn docs, `SKILL.md` ghi đính chính: `sargable_casefold`
  (11.3) chỉ áp dụng `UPPER`/`UCASE` trên `utf8mb3_general_ci` và `utf8mb4_general_ci`,
  không phải mọi collation `_ci` và không có `LOWER`; mục Histogram chỉ nêu mặc định 10.4,
  không nói 10.3 cần bật `use_stat_tables`.
- Các file `mysql-*` dùng cú pháp MySQL 8 (`EXPLAIN ANALYZE`, `utf8mb4_0900_ai_ci`,
  `INVISIBLE`, functional index, `->>`, `FOR SHARE`, `data_locks`). Bảng "MariaDB
  differences" trong `SKILL.md` dịch từng mục sang MariaDB kèm phiên bản; các mốc phiên
  bản đã đối chiếu với mariadb.com/docs ngày 2026-09-25. Khi upstream hoặc MariaDB đổi,
  đối chiếu lại bảng này; các mục trùng với file MariaDB chỉ trỏ sang mục tương ứng, không
  nêu lại.
- Cuối file MariaDB có mục "Sources" link tới `mariadb.com/docs`. Giữ nguyên.

## 2. Quy trình cập nhật từ upstream

Nguyên tắc: không sửa tay file trong `references/`. Mọi thay đổi nội dung đến từ upstream
qua quy trình dưới đây, để lần sau vẫn diff được. Nếu thật sự cần sửa một file, tách phần
sửa thành file mới với tên riêng và ghi vào mục 1.

### Bước 1. Clone hai nguồn vào thư mục tạm

```bash
TMP=$(mktemp -d)
git clone -q --depth 1 https://github.com/mariadb/skills.git "$TMP/mariadb"
git clone -q --depth 1 --filter=blob:none --sparse https://github.com/planetscale/database-skills.git "$TMP/planetscale"
git -C "$TMP/planetscale" sparse-checkout set skills/mysql

MDB="$TMP/mariadb/mariadb-query-optimization"
PSC="$TMP/planetscale/skills/mysql"
echo "mariadb     $(git -C "$TMP/mariadb" rev-parse HEAD)"
echo "planetscale $(git -C "$TMP/planetscale" rev-parse HEAD)"
grep -m1 'Last updated' "$MDB/SKILL.md"
```

Ghi lại hai commit SHA in ra. Repo MariaDB chứa nhiều skill trong cùng một repo, nên SHA
đổi không có nghĩa là file query-optimization đổi; kiểm tra bằng bước 2. Nếu cả hai SHA
trùng với bảng ở mục 1 thì upstream chưa đổi, dừng ở đây.

### Bước 2. Xem có gì thay đổi

Chạy từ thư mục `mariadb/`. Lệnh in ra ba loại kết quả: file đã đổi nội dung, file upstream
mới thêm mà skill chưa có, và file skill đang có mà upstream đã xóa.

```bash
cd mariadb

echo "== MariaDB: file đã đổi nội dung =="
cmp -s "$MDB/SKILL.md" references/mariadb-query-optimization.md || echo "  mariadb-query-optimization.md"

echo "== PlanetScale: file đã đổi nội dung =="
for f in references/mysql-*.md; do
  b=$(basename "$f"); u="${b#mysql-}"; [ -f "$PSC/references/$u" ] && ! cmp -s "$PSC/references/$u" "$f" && echo "  $b"
done
echo "== PlanetScale: file mới ở upstream =="
for f in "$PSC"/references/*.md; do
  b=$(basename "$f"); [ -f "references/mysql-$b" ] || echo "  $b"
done
echo "== PlanetScale: file upstream đã xóa =="
for f in references/mysql-*.md; do
  b=$(basename "$f"); [ -f "$PSC/references/${b#mysql-}" ] || echo "  $b"
done
```

Với file đã đổi nội dung, xem diff cụ thể trước khi lấy:

```bash
diff "$MDB/SKILL.md" references/mariadb-query-optimization.md
diff "$PSC/references/<tên>.md" references/mysql-<tên>.md
```

Khi file MariaDB đổi, đọc kỹ mục "What LLMs Get Wrong" và các mục có tag phiên bản mới;
nếu upstream nâng baseline (ví dụ lên 12.x LTS) thì rà lại bảng "MariaDB differences" và
mục 10.3 trong `SKILL.md`.

### Bước 3. Áp dụng

```bash
cd mariadb

# MariaDB: một file
cp "$MDB/SKILL.md" references/mariadb-query-optimization.md

# PlanetScale: xóa file upstream đã bỏ, rồi chép đè toàn bộ với tiền tố mysql-
for f in references/mysql-*.md; do
  b=$(basename "$f"); [ -f "$PSC/references/${b#mysql-}" ] || rm "$f"
done
for f in "$PSC"/references/*.md; do
  cp "$f" "references/mysql-$(basename "$f")"
done

# Cắt đoạn quảng cáo nhà cung cấp: mọi mục "## ..." có chữ PlanetScale và cụm
# "or **PlanetScale connection pooling**". Chạy trên toàn bộ mysql-* để bắt cả mục mới.
cat > "$TMP/strip-planetscale.py" <<'PY'
import re, sys, pathlib
for p in map(pathlib.Path, sys.argv[1:]):
    s = p.read_text()
    s = s.replace(' or **PlanetScale connection pooling**', '')
    s = re.sub(r'\n## [^\n]*PlanetScale[^\n]*\n(?:(?!## )[^\n]*\n)*', '\n', s)
    p.write_text(s.rstrip('\n') + '\n')
PY
python3 "$TMP/strip-planetscale.py" references/mysql-*.md

# License
cp "$TMP/mariadb/LICENSE" LICENSE-mariadb
cp "$TMP/planetscale/LICENSE" LICENSE-planetscale
```

Sau khi cắt, chạy `grep -rn -i 'planetscale\|vitess' references`. Nếu còn kết quả là upstream
thêm câu quảng cáo dạng mới mà script chưa bắt; sửa script rồi ghi lại vào đây.

Nếu upstream thêm file mới: thêm một dòng vào bảng chỉ mục tương ứng trong `SKILL.md`, rà
xem có cú pháp MySQL 8 nào cần thêm vào bảng "MariaDB differences", và cập nhật bảng đổi
tên ở mục 1. Nếu upstream xóa file: xóa dòng trong `SKILL.md`, ghi vào mục 1.

### Bước 4. Kiểm tra sau khi cập nhật

```bash
cd mariadb

# 19 file, trong đó 18 file mysql- (sửa con số nếu mục 1 đã thay đổi)
ls references | wc -l; ls references/mysql-* | wc -l

# Mọi link trong SKILL.md đều trỏ tới file tồn tại
for l in $(grep -o 'references/[a-z0-9-]*\.md' SKILL.md | sort -u); do [ -f "$l" ] || echo "THIẾU: $l"; done

# Mọi file trong references đều được SKILL.md link tới
for f in references/*.md; do grep -q "($f)" SKILL.md || echo "CHƯA LINK: $f"; done

# Mọi file khớp byte với upstream sau khi áp dụng cùng bước cắt lên bản upstream
cmp -s references/mariadb-query-optimization.md "$MDB/SKILL.md" || echo "KHÁC: mariadb-query-optimization.md"
rm -rf "$TMP/psc-stripped"; mkdir "$TMP/psc-stripped"; cp "$PSC"/references/*.md "$TMP/psc-stripped/"
python3 "$TMP/strip-planetscale.py" "$TMP/psc-stripped"/*.md
for f in references/mysql-*.md; do b=$(basename "$f"); cmp -s "$f" "$TMP/psc-stripped/${b#mysql-}" || echo "KHÁC: $b"; done

# Không còn chuỗi nhà cung cấp trong references
grep -rIl -i 'planetscale\|pscale\|vitess' references || echo "sạch"

# Xem upstream có đổi mô tả hoặc ngày cập nhật không, để cân nhắc cập nhật SKILL.md của mình
grep -m1 'Last updated' "$MDB/SKILL.md"; grep -m1 '^description:' "$PSC/SKILL.md"
```

### Bước 5. Ghi lại

- Cập nhật cột "Phiên bản", "Commit đã lấy", "Ngày lấy" trong bảng ở mục 1.
- Nếu tập file lấy hoặc bỏ thay đổi, sửa các danh sách ở mục 1 cho khớp.
- Xóa thư mục tạm: `rm -rf "$TMP"`.
