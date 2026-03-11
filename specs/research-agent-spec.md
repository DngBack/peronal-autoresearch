# Spec: Research Agent (Mở rộng từ Autoresearch)

**Phiên bản:** 0.2 — Đã cập nhật theo thảo luận  
**Mục đích:** Định nghĩa rõ hệ thống agent có thể đọc repo, phân tích mục tiêu do người dùng nhập, phác thảo và triển khai thí nghiệm, đánh giá qua bảng so sánh, và viết bản nháp paper. Triển khai bằng **Cursor skills**.

---

## 1. Tầm nhìn và khác biệt với Autoresearch hiện tại

| Khía cạnh | Autoresearch hiện tại | Research Agent (đề xuất) |
|-----------|------------------------|---------------------------|
| **Mục tiêu** | Tối ưu một metric (val_bpb) càng thấp càng tốt | Đạt **mục tiêu nghiên cứu** (paper goal): ví dụ “chứng minh X tốt hơn Y”, “khám phá trade-off Z”, “viết được một bài paper với bảng số và kết luận” |
| **Đầu vào** | Chỉ `program.md` + sửa `train.py` | **Research brief**: câu hỏi nghiên cứu / chủ đề paper / giả thuyết + repo (code, có thể thêm papers, docs) |
| **Hành vi** | Vòng lặp: sửa code → chạy 5 phút → keep/discard theo val_bpb | **Nhiều phase**: đọc & phân tích → phác thảo kế hoạch & thí nghiệm → chạy thí nghiệm → đánh giá → cập nhật ý tưởng/code → (lặp) → tổng hợp kết quả / viết bản nháp paper |
| **Sản phẩm** | `results.tsv` + code tốt hơn trên branch | **Research artifacts**: kế hoạch thí nghiệm, **bảng so sánh**, phân tích, và **bản nháp paper** |

Ý tưởng cốt lõi: agent không chỉ “tối ưu metric” mà **định hướng theo một câu chuyện nghiên cứu** (hypothesis → experiments → evidence → conclusion) và sinh ra artifacts phục vụ viết paper hoặc đạt mục tiêu chính của paper.

---

## 2. Mục tiêu nghiên cứu (Research Goal) — Do người dùng nhập

- **Nguồn mục tiêu:** Người dùng **nhập** mục tiêu (trong `research_brief.md` hoặc prompt). Agent **phân tích** nội dung đó rồi **triển khai** (lên kế hoạch, chạy thí nghiệm, đánh giá, viết draft).
- **Không** bắt buộc chọn "một dạng" cố định. Các ví dụ dưới chỉ dùng để **gợi ý** cho người dùng khi viết research brief; agent tự suy ra loại mục tiêu từ nội dung.

**Gợi ý cho người dùng (có thể đưa vào template):**

- **A. Hypothesis-driven**  
  Ví dụ: *“ReLU² MLP có thể thay GELU mà không làm tệ val_bpb trong budget 5 phút.”*  
  Thành công: có bảng so sánh (baseline vs ReLU²), số liệu, kết luận rõ ràng.

- **B. Exploration / theme**  
  Ví dụ: *“Khám phá trade-off depth vs width trong budget 5 phút.”*  
  Thành công: một bộ thí nghiệm có hệ thống (nhiều (depth, width)), bảng/đồ thị, nhận định.

- **C. Paper-shaped**  
  Ví dụ: *“Viết một short paper (4–6 trang) kiểu workshop: một ý tưởng nhỏ + thí nghiệm + kết quả.”*  
  Thành công: bản nháp có abstract, method, experiments, results, conclusion + code/số liệu tương ứng.

- **D. Open-ended improvement (giống hiện tại nhưng có “story”)**  
  Ví dụ: *“Cải thiện val_bpb và ghi lại mọi thay đổi quan trọng để có thể viết report ngắn giải thích cái gì đã giúp.”*  
  Thành công: results.tsv + narrative (file markdown) giải thích từng bước cải thiện.

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

- **research_plan.md** (bắt buộc):  
  - Mục tiêu nghiên cứu (tóm tắt từ research brief).  
  - Giả thuyết / câu hỏi / theme.  
  - Danh sách thí nghiệm (planned + đã chạy): tên, mô tả thay đổi, trạng thái (pending / running / done / failed), kết quả chính (val_bpb, peak_vram, v.v.).  
  - Nhận định tạm thời và bước tiếp theo.  
  Agent cập nhật file này sau mỗi phase hoặc sau mỗi nhóm thí nghiệm.

- **results.tsv** (giữ): commit, val_bpb, memory_gb, status, description (+ có thể experiment_id để map với plan).

- **Bảng so sánh (bắt buộc cho đánh giá):**  
  - Kết quả cần được **đánh giá qua bảng so sánh** (baseline vs từng thí nghiệm / ablations).  
  - Agent tạo ít nhất một **bảng chính** (markdown hoặc CSV): các cột ví dụ — experiment name, val_bpb, memory_gb, mô tả thay đổi; hàng = baseline + từng run.  
  - Bảng có thể nằm trong `research_plan.md` (phần "Results summary") và/hoặc trong `draft/paper.md` (phần Experiments/Results).  
  - Mục đích: human và agent đều dựa vào bảng để so sánh và kết luận.

- **Bản nháp paper (draft) — có:**  
  - File markdown (vd `draft/paper.md`) hoặc LaTeX (`draft/paper.tex`).  
  - Cấu trúc: Abstract, 1. Intro/Goal, 2. Method (codebase, metric, time budget), 3. Experiments (**bảng so sánh** + mô tả), 4. Results & Discussion, 5. Conclusion, References.  
  - Agent điền dần khi đủ thí nghiệm; bảng số lấy từ bảng so sánh đã tạo; human chỉnh style và nội dung sau.

---

## 4. Quy trình (Phases & Loop)

### 4.1 Khởi tạo (một lần)

1. Human cung cấp **research brief**: mục tiêu nghiên cứu (hypothesis / theme / target paper), success criteria (nếu có), ràng buộc (chỉ train.py, 5 phút, v.v.).
2. Agent đọc repo (README, prepare.py, train.py, program.md) và (nếu có) papers/docs.
3. Agent tạo/ghi **research_plan.md**: tóm tắt goal, giả thuyết, và **danh sách thí nghiệm dự kiến** (sketch): ít nhất baseline + vài hướng (ví dụ ablation A, B, C).
4. Human xác nhận (hoặc bỏ qua nếu chạy autonomous): có thể chỉnh research_plan hoặc OK để chạy.

### 4.2 Vòng lặp thí nghiệm (Experiment Loop)

Lặp cho đến khi đạt success criteria hoặc hết budget (số run / thời gian):

1. **Chọn thí nghiệm:** Từ research_plan chọn một thí nghiệm “pending” (hoặc sinh thí nghiệm mới dựa trên kết quả trước).
2. **Sửa code:** Thay đổi `train.py` theo mô tả thí nghiệm (ví dụ đổi activation, depth, LR).
3. **Chạy:** `uv run train.py > run.log 2>&1`, đọc `val_bpb`, `peak_vram_mb` (và lỗi nếu crash).
4. **Ghi nhận:** Cập nhật results.tsv; cập nhật research_plan.md (trạng thái thí nghiệm, số liệu, nhận định ngắn).
5. **Đánh giá:** So sánh với baseline và với các thí nghiệm trước; quyết định keep/discard (git) như hiện tại; quyết định bước tiếp theo (thí nghiệm tiếp theo, điều chỉnh giả thuyết, hoặc kết thúc phase).
6. **Cập nhật kế hoạch (nếu cần):** Thêm thí nghiệm mới, sửa giả thuyết, hoặc ghi nhận “đủ evidence để viết kết luận”.

### 4.3 Tổng hợp và viết (Synthesis)

- Khi agent xác định đã đủ thí nghiệm (theo success criteria hoặc heuristic):  
  - Tổng hợp bảng số từ results.tsv + research_plan.  
  - (Tùy chọn) Tạo hoặc cập nhật **draft/paper.md** (hoặc .tex): điền method, experiments, results, discussion, conclusion.  
- Human có thể chỉnh draft sau; agent không cần “hoàn chỉnh” văn phong, chỉ cần nội dung và số liệu đúng.

### 4.4 Tương tác với Human

- **Bắt buộc:** Research brief ban đầu (và có thể success criteria).  
- **Tùy chọn:** Duyệt research_plan trước khi chạy; duyệt draft; yêu cầu “dừng sau N run” hoặc “chỉ chạy list thí nghiệm này”.  
- **Autonomous:** Trong vòng lặp, agent không dừng để hỏi “có tiếp tục không?” (giống program.md); chỉ dừng khi đạt criteria hoặc bị human dừng.

---

## 5. Cấu trúc repo đề xuất (sau khi triển khai)

```
peronal-autoresearch/
├── prepare.py
├── train.py
├── program.md              # (có thể mở rộng hoặc thêm research-agent.md)
├── research_brief.md       # Human viết: goal, hypothesis, criteria (optional)
├── research_plan.md        # Agent tạo/cập nhật: plan, experiments, findings
├── results.tsv
├── run.log
├── specs/
│   └── research-agent-spec.md
├── draft/                  # (optional)
│   └── paper.md            # Bản nháp paper/report
└── ...
```

- `research_brief.md`: đầu vào từ human (mục tiêu nghiên cứu, giới hạn).  
- `research_plan.md`: đầu ra/state của agent (sketch ý tưởng, thí nghiệm, kết quả tóm tắt).  
- `draft/paper.md`: agent điền nội dung và số liệu khi đủ thí nghiệm (bắt buộc trong spec).

---

## 6. Ràng buộc kỹ thuật

- **Một GPU**; **nhiều file** có thể sửa (train.py, experiments/, script phân tích; prepare.py nếu research brief cho phép).  
- **Time budget:** cấu hình được trong research brief (vd 5, 10, 15 phút); mặc định 5 phút. Timeout kill = 2× budget (tối đa 20 phút).  
- **Metric chính:** val_bpb (từ prepare.py; không sửa logic eval trừ khi brief cho phép).  
- **Dependency:** mặc định không thêm; chỉ khi research brief cho phép.  
- **Git:** Branch per run tag (autoresearch/&lt;tag&gt;); keep/discard bằng commit/reset. results.tsv có thể untracked.

---

## 7. Đã chốt (từ thảo luận)

- **Mục tiêu:** Do người dùng nhập (research_brief); agent phân tích và triển khai; có thể gợi ý template.  
- **Time budget:** Cấu hình được (5 phút khá chặt vì đã gồm train); user có thể đặt 10, 15 phút.  
- **Kết quả:** Đánh giá qua **bảng so sánh** (baseline vs từng thí nghiệm); bắt buộc có bảng.  
- **Draft paper:** Có; agent điền khi đủ thí nghiệm.  
- **Sửa code:** Mở rộng nhiều file; triển khai bằng **Cursor skills** để quy định workflow và phạm vi sửa.  
- **Đọc thêm:** Agent đọc papers/URL khi cần thiết để cải thiện ý tưởng và kết quả.
## 8. Bước tiếp theo (sau khi ưng spec)

1. **Template:** Tạo `research_brief.md` (template) với trường: mục tiêu (text), time_budget_minutes (optional), success criteria (optional), gợi ý đọc thêm (URL/papers, optional).  
2. **Cursor skills:** Thiết kế và viết các skills cho Research Agent:
   - Skill "research-setup": đọc repo + research_brief, tạo research_plan.md.
   - Skill "research-experiment": chọn thí nghiệm, sửa code (nhiều file theo spec), chạy train, ghi results + cập nhật plan.
   - Skill "research-synthesis": tổng hợp bảng so sánh, viết/ cập nhật draft/paper.md.
   - Skill "research-read-external": khi cần, fetch/đọc URL hoặc tài liệu để cải thiện ý tưởng.
3. **Cấu hình time budget:** Cho phép override TIME_BUDGET (vd qua biến môi trường hoặc file config) để agent/human đặt từ research_brief.  
4. **Integration:** Cập nhật `program.md` hoặc thêm instruction trỏ tới research_brief + skills (workflow: đọc brief → plan → experiment loop → bảng so sánh → draft paper).  
5. **Test:** Chạy với một research brief cụ thể (vd hypothesis đơn giản) và chỉnh spec/skills nếu cần.

---

*Tài liệu này là bản spec để thảo luận; chỉ triển khai code/instruction sau khi đã thống nhất.*
