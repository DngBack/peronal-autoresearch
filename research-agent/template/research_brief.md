# Research Brief

Điền nội dung dưới đây để bắt đầu một đợt research. Agent sẽ đọc file này, phân tích mục tiêu, lên kế hoạch thí nghiệm và triển khai theo spec trong `specs/research-agent-spec.md`.

---

## 1. Mục tiêu nghiên cứu (bắt buộc)

Mô tả rõ mục tiêu: giả thuyết cần kiểm chứng, câu hỏi cần trả lời, hoặc chủ đề paper bạn muốn hướng tới.

**Ví dụ gợi ý:**
- *So sánh ReLU² vs GELU trong MLP: val_bpb trong budget train cố định.*
- *Khám phá trade-off depth vs width (số layer vs n_embd) trên metric val_bpb.*
- *Viết short paper 4–6 trang: một ý tưởng nhỏ (vd activation, LR schedule) + thí nghiệm + bảng kết quả + kết luận.*

**Mục tiêu của tôi:**

<!-- Viết vào đây -->



---

## 2. Time budget (tùy chọn)

Thời gian train (giây) cho mỗi run. Mặc định repo dùng 300 (5 phút). Có thể tăng nếu cần thí nghiệm dài hơn (vd 600 = 10 phút, 900 = 15 phút).

- **time_budget_minutes:** <!-- số phút, vd 5 hoặc 10. Để trống = dùng mặc định 5 -->

**Lưu ý:** Giá trị thực tế được áp dụng qua `TIME_BUDGET` (giây) trong code hoặc config; nếu repo hỗ trợ override từ đây, agent sẽ dùng số phút × 60.

---

## 3. Success criteria (tùy chọn)

Điều kiện để coi research "xong" (agent có thể dừng vòng lặp và chuyển sang tổng hợp / viết draft).

**Ví dụ:**
- Ít nhất 3 ablations + 1 bảng so sánh đầy đủ.
- Có 1 bảng so sánh baseline vs ít nhất 2 biến thể + 1 đoạn kết luận ngắn.
- Đủ evidence để điền đủ các phần của draft paper (method, experiments, results, conclusion).

**Success criteria của tôi:**

<!-- Viết vào đây, hoặc để trống -->



---

## 4. Gợi ý đọc thêm (tùy chọn)

URL hoặc tên paper/tài liệu agent nên đọc khi cần để cải thiện ý tưởng hoặc thiết kế thí nghiệm (related work, baseline, trick).

**URLs hoặc tài liệu:**

<!-- Ví dụ: https://arxiv.org/abs/xxxx.xxxxx, link blog, path trong repo (vd docs/xyz.md) -->



---

## 5. Ràng buộc bổ sung (tùy chọn)

- Có được sửa `prepare.py` không? (mặc định: không; chỉ khi bạn ghi rõ "được sửa prepare.py" hoặc tương tự.)
- Có được thêm dependency mới không? (mặc định: không.)
- Giới hạn số run tối đa? (vd "tối đa 10 run" — để trống = không giới hạn cứng.)

**Ràng buộc:**

<!-- Viết vào đây -->

