<%@ include file="../layout/header.jsp" %>
    <%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
        <%@ taglib prefix="c" uri="jakarta.tags.core" %>

            <div class="page-header mb-4">
                <h2 class="mb-1">Log Time Entry</h2>
                <p class="text-muted mb-0">Record effort spent on this work package.</p>
            </div>

            <div class="section-card" style="max-width:560px">
                <form:form method="post" modelAttribute="timeEntry"
                    action="${pageContext.request.contextPath}/work-packages/${workPackageId}/time-entries">
                    <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />

                    <div class="row g-4">
                        <div class="col-md-6">
                            <form:label path="hours" class="form-label">Hours *</form:label>
                            <form:input path="hours" type="number" step="0.25" min="0.25" class="form-control"
                                required="true" placeholder="e.g. 2.5" />
                            <form:errors path="hours" cssClass="text-danger" />
                        </div>
                        <div class="col-md-6">
                            <form:label path="spentOn" class="form-label">Date *</form:label>
                            <form:input path="spentOn" type="date" class="form-control" required="true" />
                        </div>
                        <div class="col-12">
                            <form:label path="comment" class="form-label">Comment</form:label>
                            <form:textarea path="comment" class="form-control" rows="3"
                                placeholder="Optional notes about this time entry" />
                        </div>
                        <div class="col-12 d-flex flex-wrap gap-2">
                            <button type="submit" class="btn btn-primary">
                                <i class="bi bi-check-lg me-1"></i>Save Entry
                            </button>
                            <a href="${pageContext.request.contextPath}/work-packages/${workPackageId}"
                                class="btn btn-outline-primary">
                                <i class="bi bi-x-lg me-1"></i>Cancel
                            </a>
                        </div>
                    </div>
                </form:form>
            </div>

            <%@ include file="../layout/footer.jsp" %>
