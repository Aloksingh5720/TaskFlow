<div
  class="modal fade"
  id="bulkUploadModal"
  tabindex="-1"
  aria-labelledby="bulkUploadModalLabel"
  aria-hidden="true"
>
  <div class="modal-dialog modal-lg">
    <div class="modal-content rounded-4">
      <form
        action="${pageContext.request.contextPath}/admin/users/import"
        method="post"
        enctype="multipart/form-data"
      >
        <!-- CSRF Token -->
        <input
          type="hidden"
          name="${_csrf.parameterName}"
          value="${_csrf.token}"
        />

        <div class="modal-header bg-success bg-opacity-10 rounded-top-4">
          <h5 class="modal-title" id="bulkUploadModalLabel">
            <i class="bi bi-cloud-upload me-2"></i> Bulk User Import
          </h5>
          <button
            type="button"
            class="btn-close"
            data-bs-dismiss="modal"
            aria-label="Close"
          ></button>
        </div>

        <div class="modal-body">
          <div class="mb-4">
            <label for="csvFile" class="form-label fw-bold">
              <i class="bi bi-filetype-csv me-1"></i> CSV File
            </label>
            <input
              type="file"
              class="form-control rounded-3"
              id="csvFile"
              name="file"
              accept=".csv, .text/csv"
              required
            />
            <div class="form-text mt-2">
              <i class="bi bi-info-circle"></i> Maximum file size: 10MB
            </div>
          </div>

          <div class="mb-4">
            <h6 class="fw-bold mb-2">
              <i class="bi bi-table me-1"></i> Required Columns
            </h6>
            <code class="d-block p-3 bg-light rounded-3 border"
              >username, email, password, name, enabled, globalRoleId</code
            >
          </div>

          <div class="mb-3">
            <h6 class="fw-bold mb-2">
              <i class="bi bi-file-code me-1"></i> Example CSV Format
            </h6>
            <div class="border rounded-3 p-3">
              <code class="d-block mb-3 bg-light p-3 rounded-3">
                username,email,password,name,enabled,globalRoleId<br />
                "krishna","krishna@nexabyt.com","krishna@123","Krishna
                Kumar","true","2"
              </code>

              <div class="mt-2 pt-2 border-top">
                <div class="fw-bold small mb-2">Global Role ID Reference:</div>
                <div class="d-flex gap-3 small">
                  <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-success rounded-pill">2</span>
                    <span>ADMIN</span>
                  </div>
                  <div class="d-flex align-items-center gap-2">
                    <span class="badge bg-primary rounded-pill">3</span>
                    <span>USER</span>
                  </div>
                </div>
              </div>
            </div>
          </div>

          <!-- Hidden Fields -->
          <input type="hidden" name="page" value="${currentPage}" />
          <input type="hidden" name="sortField" value="${sortField}" />
          <input type="hidden" name="sortDir" value="${sortDir}" />
          <c:if test="${not empty search}">
            <input type="hidden" name="search" value="${search}" />
          </c:if>
        </div>

        <div class="modal-footer bg-light rounded-bottom-4">
          <button
            type="button"
            class="btn btn-secondary rounded-3"
            data-bs-dismiss="modal"
          >
            <i class="bi bi-x-lg"></i> Cancel
          </button>
          <button type="submit" class="btn btn-success rounded-3">
            <i class="bi bi-cloud-upload"></i> Import Users
          </button>
        </div>
      </form>
    </div>
  </div>
</div>
