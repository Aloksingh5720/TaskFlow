<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="modal fade" id="editProjectModal" tabindex="-1" aria-labelledby="editProjectModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content rounded-2">
            <form id="editProjectForm" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                <div class="modal-header">
                    <div>
                        <h5 class="modal-title mb-1" id="editProjectModalLabel">Edit Project</h5>
                        <p class="mb-0 text-muted small">Update the project details below.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-12">
                            <label for="editProjectName" class="form-label">Name *</label>
                            <input type="text" id="editProjectName" name="name" class="form-control" required />
                        </div>
                        <div class="col-12">
                            <label for="editProjectDescription" class="form-label">Description</label>
                            <textarea id="editProjectDescription" name="description" class="form-control" rows="3"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label for="editProjectParent" class="form-label">Parent Project</label>
                            <select id="editProjectParent" name="parentId" class="form-select">
                                <option value="">None (Top-level)</option>
                                <c:forEach items="${parentProjects}" var="p">
                                    <option value="${p.id}">${p.name}</option>
                                </c:forEach>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label for="editProjectStatus" class="form-label">Status</label>
                            <select id="editProjectStatus" name="projectStatus" class="form-select">
                                <c:forEach items="${projectStatuses}" var="status">
                                    <option value="${status}">${status.name().replace('_', ' ')}</option>
                                </c:forEach>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-lg me-1"></i>Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    (function () {
        var editProjectModal = document.getElementById('editProjectModal');
        if (!editProjectModal) return;
        editProjectModal.addEventListener('show.bs.modal', function (event) {
            var trigger = event.relatedTarget;
            if (!trigger) return;
            var form = editProjectModal.querySelector('#editProjectForm');
            if (form) form.setAttribute('action', trigger.getAttribute('data-edit-action') || '');
            var nameInput = editProjectModal.querySelector('#editProjectName');
            if (nameInput) nameInput.value = trigger.getAttribute('data-project-name') || '';
            var descInput = editProjectModal.querySelector('#editProjectDescription');
            if (descInput) descInput.value = trigger.getAttribute('data-project-description') || '';
            var parentSelect = editProjectModal.querySelector('#editProjectParent');
            if (parentSelect) parentSelect.value = trigger.getAttribute('data-project-parent-id') || '';
            var statusSelect = editProjectModal.querySelector('#editProjectStatus');
            if (statusSelect) statusSelect.value = trigger.getAttribute('data-project-status') || '';
        });
    })();
</script>
