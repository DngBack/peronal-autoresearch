# Spec: Research Agent (Mở rộng từ Autoresearch)

**Phiên bản:** 0.2 — Đã cập nhật theo thảo luận  
**Mục đích:** Định nghĩa rõ hệ thống agent có thể đọc repo, phân tích mục tiêu do người dùng nhập, phác thảo và triển khai thí nghiệm, đánh giá qua bảng so sánh, và viết bản nháp paper. Triển khai bằng **Cursor skills**.

---

## 1. Tầm nhìn và khác biệt với Autoresearch hiện tại

| Khía cạnh | Autoresearch hiện tại | Research Agent (đề xuất) |
|-----------|------------------------|---------------------------|
| **Mục tiêu** | Tối ưu một metric (val_bpb) càng thấp càng tốt | Đạt **mục tiêu nghiên cứu** (paper goal): ví dụ "chứng minh X tốt hơn Y", "khám phá trade-off Z", "viết được một bài paper với bảng số và kết luận" |
| **Đầu vào** | Chỉ `program.md` + sửa `train.py` | **Research brief**: câu hỏi nghiên cứu / chủ đề paper / giả thuyết + repo (code, có thể thêm papers, docs) |
| **Hành vi** | Vòng lặp: sửa code → chạy 5 phút → keep/discard theo val_bpb | **Nhiều phase**: đọc & phân tích → phác thảo kế hoạch & thí nghiệm → chạy thí nghiệm → đánh giá → cập nhật ý tưởng/code → (lặp) → tổng hợp kết quả / viết bản nháp paper |
| **Sản phẩm** | `results.tsv` + code tốt hơn trên branch | **Research artifacts**: kế hoạch thí nghiệm, **bảng so sánh**, phân tích, và **bản nháp paper** |

Ý tưởng cốt lõi: agent không chỉ "tối ưu metric" mà **định hướng theo một câu chuyện nghiên cứu** (hypothesis → experiments → evidence → conclusion) và sinh ra artifacts phục vụ viết paper hoặc đạt mục tiêu chính của paper.

---

## 2. Mục tiêu nghiên cứu (Research Goal) — Do người dùng nhập

- **Nguồn mục tiêu:** Người dùng **nhập** mục tiêu (trong `research_brief.md` hoặc prompt). Agent **phân tích** nội dung đó rồi **triển khai** (lên kế hoạch, chạy thí nghiệm, đánh giá, viết draft).
- **Không** bắt buộc chọn "một dạng" cố định. Các ví dụ dưới chỉ dùng để **gợi ý** cho người dùng khi viết research brief; agent tự suy ra loại mục tiêu từ nội dung.

**Gợi ý cho người dùng (có thể đưa vào template):**

- **A. Hypothesis-driven:** *"ReLU² MLP có thể thay GELU mà không làm tệ val_bpb."* → Agent thiết kế baseline + ablation, so sánh bảng.
- **B. Exploration:** *"Khám phá trade-off depth vs width."* → Agent chạy lưới thí nghiệm, lập bảng/đồ thị.
- **C. Paper-shaped:** *"Viết short paper 4–6 trang: ý tưởng X + thí nghiệm + kết quả."* → Agent thu thập evidence và điền draft.
- **D. Open-ended:** *"Cải thiện val_bpb và ghi lại từng thay đổi quan trọng để có report."* → Agent vừa tối ưu vừa narrative.

**Success criteria** (nếu có) do người dùng ghi trong research brief (vd: ít nhất 3 ablations, có 1 bảng so sánh đầy đủ, có bản nháp paper).

---

## 3. Agent có thể làm gì (Capabilities)

### 3.1 Đọc (Read)

- **Repo:** toàn bộ code trong repo (ít nhất `prepare.py`, `train.py`, `program.md`, `README.md`; tùy chọn thêm `analysis.ipynb`, `pyproject.toml`). Có thể quy ước thư mục `papers/` hoặc `docs/` nếu thêm tài liệu.
- **Artifacts tự sinh:** `research_plan.md`, `results.tsv`, bảng so sánh, logs, bản nháp paper — agent đọc lại để tiếp tục vòng lặp.
- **Ngoài repo — đọc thêm khi cần thiết:**  
  - Agent **có thể** đọc papers, blog, repo khác (URL/PDF) **khi thấy cần** để cải thiện ý tưởng hoặc thiết kế thí nghiệm (vd: related work, baseline từ paper, trick từ blog).  
  - Tool: fetch URL / tóm tắt nội dung; nguồn có thể do human gợi ý trong research brief hoặc agent tự tìm.  
  - Ràng buộc: giới hạn số nguồn hoặc độ dài đọc để tránh lạc đề; ưu tiên nguồn liên quan trực tiếp đến mục tiêu.

**Ràng buộc:** Giới hạn độ dài context (số file / token); ưu tiên file in scope theo spec.

### 3.2 Sửa code (Edit) — Mở rộng nhiều file

- **Phạm vi cho phép:** Agent có thể sửa **nhiều file** khi cần cho nghiên cứu:
  - `train.py` (model, optimizer, hyperparameters, training loop) — chính.
  - Thêm/sửa file trong `experiments/` (vd từng ablation có script riêng), hoặc script phân tích/eval (vd `analysis.py`, `eval_*.py`).
  - Có thể mở rộng sửa `prepare.py` nếu research brief cho phép (vd thêm metric, thêm dataset) — khi đó cần chạy lại `uv run prepare.py`.
  - Thêm dependency: chỉ khi research brief cho phép và ghi rõ trong plan; mặc định ưu tiên không thêm để giữ reproducibility.
- **Triển khai bằng Cursor skills:**  
  - Research agent được triển khai dưới dạng **Cursor skills** (rules/skills trong `.cursor/` hoặc skill repo): mỗi skill mô tả một nhiệm vụ (đọc repo, phân tích goal, lên kế hoạch, sửa nhiều file, chạy thí nghiệm, tạo bảng so sánh, viết draft paper).  
  - Agent (Cursor) đọc skills và thực hiện theo workflow; skills quy định phạm vi file được sửa, format artifacts, và ràng buộc (time budget, metric).  
  - Điều này cho phép sửa nhiều file có kiểm soát và tái sử dụng workflow cho project khác.

### 3.3 Chạy (Run)

- **Lệnh chính:** `uv run train.py` (có thể redirect `> run.log 2>&1` như hiện tại).
- **Time budget — cấu hình được:**  
  - Budget 5 phút (chỉ train) **khá chặt** vì đã gồm toàn bộ thời gian train; trong research brief người dùng có thể chỉ định **time_budget_minutes** (vd 5, 10, 15).  
  - Code (train.py / prepare.py) cần đọc constant từ research brief hoặc từ file cấu hình (vd `TIME_BUDGET` trong prepare.py có thể override bằng biến môi trường hoặc file config) để agent/human đặt budget phù hợp.  
  - Timeout kill run: tỷ lệ với budget (vd 2× time_budget, tối đa 20 phút) để tránh treo.
- **Tùy chọn:**  
  - `uv run prepare.py` khi có thay đổi data/tokenizer (và research brief cho phép).  
  - Script phân tích: `uv run analysis.py` hoặc notebook export — agent gọi nếu file tồn tại và được phép.

### 3.4 Viết (Write) — Artifacts nghiên cứu

- **research_plan.md** (bắt buộc): Mục tiêu, giả thuyết, danh sách thí nghiệm (planned + đã chạy), nhận định / bước tiếp theo.
- **results.tsv** (giữ): commit, val_bpb, memory_gb, status, description.
- **Bảng so sánh (bắt buộc):** baseline vs từng thí nghiệm; nằm trong research_plan (Results summary) và/hoặc draft/paper.md.
- **Bản nháp paper:** draft/paper.md — Abstract, Intro, Method, Experiments (bảng), Results & Discussion, Conclusion, References.

---

## 4. Quy trình (Phases & Loop)

- **4.1 Khởi tạo:** Human cung cấp research_brief → Agent đọc repo (+ đọc thêm nếu cần) → tạo research_plan.md (goal, thí nghiệm planned).
- **4.2 Experiment loop:** Chọn thí nghiệm → sửa code → chạy → ghi results + cập nhật plan → keep/discard → lặp đến khi đủ success criteria.
- **4.3 Synthesis:** Tổng hợp bảng so sánh → viết/cập nhật draft/paper.md.
- **4.4 Autonomous:** Trong vòng lặp agent không dừng hỏi "có tiếp tục không?"; chỉ dừng khi đạt criteria hoặc human dừng.

---

## 5. Cấu trúc repo (sau setup)

- `research_brief.md` — Human điền (mục tiêu, time budget, success criteria, đọc thêm, ràng buộc).
- `research_plan.md` — Agent tạo/cập nhật (plan, experiments, bảng summary).
- `specs/research-agent-spec.md` — Spec (từ repo research-agent).
- `.cursor/skills/` — research-setup, research-experiment, research-synthesis, research-read-external.
- `draft/paper.md` — Agent điền khi đủ thí nghiệm.

---

## 6. Ràng buộc kỹ thuật

- Một GPU; nhiều file có thể sửa (train.py, experiments/, prepare nếu brief cho phép).
- Time budget cấu hình được; timeout = 2× budget (tối đa 20 phút).
- Metric chính: val_bpb (hoặc metric repo đang dùng); không sửa logic eval trừ khi brief cho phép.
- Dependency: mặc định không thêm.

---

*Spec đầy đủ có thể mở rộng; bản này là bản rút gọn cho repo research-agent.*
