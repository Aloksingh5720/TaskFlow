<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="modal fade" id="createIssueModal" tabindex="-1" aria-labelledby="createIssueModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-2">
            <form id="createIssueForm" method="post" action="${pageContext.request.contextPath}/work-packages/${workPackage.id}/issue">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                <div class="modal-header">
                    <div>
                        <h5 class="modal-title mb-1" id="createIssueModalLabel">Raise Issue</h5>
                        <p class="mb-0 text-muted small">Log an issue against this work package for follow-up and resolution.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label for="issueTitle" class="form-label">Title *</label>
                            <input type="text" id="issueTitle" name="title" class="form-control"
                                required placeholder="Short summary of the issue" />
                        </div>
                        <div class="col-12">
                            <label for="issueDescription" class="form-label">Description *</label>
                            <textarea id="issueDescription" name="description" class="form-control" rows="5"
                                required placeholder="Describe the issue, impact, and any context the accountable owner should know."></textarea>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-danger">
                        <i class="bi bi-flag-fill me-1"></i>Submit Issue
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    document.addEventListener('DOMContentLoaded', function() {
        var createIssueModal = document.getElementById('createIssueModal');
        if (createIssueModal) {
            createIssueModal.addEventListener('show.bs.modal', function (event) {
                var button = event.relatedTarget;
                if (!button) return;
                var action = button.getAttribute('data-issue-action');
                if (action) {
                    var form = createIssueModal.querySelector('#createIssueForm');
                    if (form) form.setAttribute('action', action);
                }
            });
        }
    });
</script>
