<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="page-header mb-4">
    <h2 class="mb-1">Raise Issue</h2>
    <p class="text-muted mb-0">Log an issue against the selected work package for follow-up and resolution.</p>
    <p class="text-muted mb-0 mt-2">
        Work package:
        <strong>
            <a href="${pageContext.request.contextPath}/work-packages/${workPackage.id}">${workPackage.subject}</a>
        </strong>
    </p>
</div>

<c:url var="formAction" value="/work-packages/${workPackage.id}/issue" />

<div class="section-card" style="max-width:860px">
    <form:form method="post" modelAttribute="issue" action="${formAction}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        <form:hidden path="id" />

        <div class="row g-4">
            <div class="col-12">
                <form:label path="title" class="form-label">Title *</form:label>
                <form:input path="title" class="form-control" required="true"
                    placeholder="Short summary of the issue" />
                <form:errors path="title" cssClass="text-danger" />
            </div>

            <div class="col-12">
                <form:label path="description" class="form-label">Description *</form:label>
                <form:textarea path="description" class="form-control" rows="6" required="true"
                    placeholder="Describe the issue, impact, and any context the accountable owner should know." />
                <form:errors path="description" cssClass="text-danger" />
            </div>

            <div class="col-12 d-flex flex-wrap gap-2 pt-2">
                <button type="submit" class="btn btn-danger-strong">
                    <i class="bi bi-flag-fill me-1"></i>Submit Issue
                </button>
                <a href="${pageContext.request.contextPath}/work-packages/${workPackage.id}" class="btn btn-outline-primary">
                    <i class="bi bi-arrow-left me-1"></i>Back to Work Package
                </a>
            </div>
        </div>
    </form:form>
</div>

<%@ include file="../layout/footer.jsp" %>
