<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<div class="modal fade" id="createTimeEntryModal" tabindex="-1" aria-labelledby="createTimeEntryModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content rounded-2">
            <form method="post" action="${pageContext.request.contextPath}/work-packages/${workPackage.id}/time-entries">
                <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                <div class="modal-header">
                    <div>
                        <h5 class="modal-title mb-1" id="createTimeEntryModalLabel">Log Time Entry</h5>
                        <p class="mb-0 text-muted small">Record effort spent on this work package.</p>
                    </div>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                </div>

                <div class="modal-body">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label for="timeEntryHours" class="form-label">Hours *</label>
                            <input type="number" id="timeEntryHours" name="hours" class="form-control"
                                step="0.25" min="0.25" required placeholder="e.g. 2.5" />
                        </div>
                        <div class="col-md-6">
                            <label for="timeEntryDate" class="form-label">Date *</label>
                            <input type="date" id="timeEntryDate" name="spentOn" class="form-control" required />
                        </div>
                        <div class="col-12">
                            <label for="timeEntryComment" class="form-label">Comment</label>
                            <textarea id="timeEntryComment" name="comment" class="form-control" rows="3"
                                placeholder="Optional notes about this time entry"></textarea>
                        </div>
                    </div>
                </div>

                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn btn-primary">
                        <i class="bi bi-check-lg me-1"></i>Save Entry
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>
