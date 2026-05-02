<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="modal fade" id="editMemberModal" tabindex="-1" aria-labelledby="editMemberModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-2">
            <form id="editMemberForm" method="post">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                <div class="modal-header">
                    <div>
                        <h5 class="modal-title mb-1" id="editMemberModalLabel">Edit Member Role</h5>
                        <p class="mb-0 text-muted small">Update role for <strong id="editMemberUsername"></strong>.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <div class="col-12">
                        <label class="form-label">Project Role *</label>
                        <div class="p-3 rounded"
                            style="background:var(--md-surface-container-low);border:1px solid var(--md-outline-variant)">
                            <div class="row g-2">
                                <c:forEach items="${roles}" var="role">
                                    <div class="col-md-6">
                                        <div class="form-check">
                                            <input type="radio" name="roleId" value="${role.id}"
                                                class="form-check-input" id="editMemberRole${role.id}" required />
                                            <label class="form-check-label" for="editMemberRole${role.id}">${role.name}</label>
                                        </div>
                                    </div>
                                </c:forEach>
                            </div>
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
        var editMemberModal = document.getElementById('editMemberModal');
        if (!editMemberModal) return;
        editMemberModal.addEventListener('show.bs.modal', function (event) {
            var trigger = event.relatedTarget;
            if (!trigger) return;
            var action = trigger.getAttribute('data-edit-action');
            var username = trigger.getAttribute('data-member-username');
            var roleId = trigger.getAttribute('data-member-role-id');
            var form = editMemberModal.querySelector('#editMemberForm');
            var usernameEl = editMemberModal.querySelector('#editMemberUsername');
            if (form && action) form.setAttribute('action', action);
            if (usernameEl && username) usernameEl.textContent = username;
            editMemberModal.querySelectorAll('input[name="roleId"]').forEach(function (radio) {
                radio.checked = radio.value === roleId;
            });
        });
    })();
</script>
