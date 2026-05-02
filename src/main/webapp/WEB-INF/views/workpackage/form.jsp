<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="form" uri="http://www.springframework.org/tags/form" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>
<%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

<div class="page-header mb-4">
    <h2 class="mb-1">${workPackage.id == null ? 'Create Work Package' : 'Edit Work Package'}</h2>
    <p class="text-muted mb-0">Capture task details, ownership, and delivery timeline.</p>
    <c:if test="${workPackage.id != null}">
        <p class="text-muted mb-0 mt-2">
            Project:
            <strong>${not empty workPackage.projectName ? workPackage.projectName : workPackage.projectId}</strong>
        </p>
    </c:if>
</div>

<c:url var="formAction"
    value="${workPackage.id == null ? '/work-packages' : '/work-packages/'}${workPackage.id == null ? '' : workPackage.id}" />

<div class="section-card" style="max-width:860px">
    <form:form method="post" modelAttribute="workPackage" action="${formAction}">
        <input type="hidden" name="${_csrf.parameterName}" value="${_csrf.token}" />
        <form:hidden path="id" />
        <c:if test="${workPackage.id != null}">
            <form:hidden path="projectId" />
        </c:if>

        <div class="row g-4">
            <c:if test="${workPackage.id == null}">
                <div class="col-md-6">
                    <form:label path="projectId" class="form-label">Project *</form:label>
                    <form:select path="projectId" class="form-select" required="true">
                        <form:option value="" label="-- Select Project --" />
                        <form:options items="${projects}" itemValue="id" itemLabel="name" />
                    </form:select>
                    <form:errors path="projectId" cssClass="text-danger" />
                </div>
            </c:if>

            <div class="col-md-4">
                <form:label path="workPackageType" class="form-label">Type *</form:label>
                <form:select path="workPackageType" class="form-select" required="true">
                    <form:option value="" label="-- Select Type --" />
                    <c:forEach items="${types}" var="type">
                        <form:option value="${type.name()}">${fn:replace(type.name(), '_', ' ')}</form:option>
                    </c:forEach>
                </form:select>
                <form:errors path="workPackageType" cssClass="text-danger" />
            </div>

            <div class="col-md-4">
                <form:label path="workPackageStatus" class="form-label">Status *</form:label>
                <form:select path="workPackageStatus" class="form-select" required="true">
                    <form:option value="" label="-- Select Status --" />
                    <c:forEach items="${statuses}" var="status">
                        <form:option value="${status.name()}">${fn:replace(status.name(), '_', ' ')}</form:option>
                    </c:forEach>
                </form:select>
                <form:errors path="workPackageStatus" cssClass="text-danger" />
            </div>

            <div class="col-md-4">
                <form:label path="workPackagePriority" class="form-label">Priority *</form:label>
                <form:select path="workPackagePriority" class="form-select" required="true">
                    <form:option value="" label="-- Select Priority --" />
                    <c:forEach items="${priorities}" var="priority">
                        <form:option value="${priority.name()}">${fn:replace(priority.name(), '_', ' ')}</form:option>
                    </c:forEach>
                </form:select>
                <form:errors path="workPackagePriority" cssClass="text-danger" />
            </div>

            <div class="col-12">
                <form:label path="subject" class="form-label">Subject *</form:label>
                <form:input path="subject" class="form-control" required="true"
                    placeholder="Short descriptive title" />
                <form:errors path="subject" cssClass="text-danger" />
            </div>

            <div class="col-12">
                <form:label path="description" class="form-label">Description *</form:label>
                <form:textarea path="description" class="form-control" rows="5" required="true"
                    placeholder="Detailed description, acceptance criteria, etc." />
                <form:errors path="description" cssClass="text-danger" />
            </div>

            <div class="col-md-3">
                <form:label path="accountableId" class="form-label">Accountable</form:label>
                <form:select path="accountableId" class="form-select">
                    <form:option value="" label="-- Not Set --" />
                    <c:forEach items="${projectMembers}" var="member">
                        <form:option value="${member.userId}">${member.username}</form:option>
                    </c:forEach>
                </form:select>
                <form:errors path="accountableId" cssClass="text-danger" />
            </div>

            <div class="col-md-3">
                <form:label path="assigneeId" class="form-label">Assignee</form:label>
                <form:select path="assigneeId" class="form-select">
                    <form:option value="" label="-- Unassigned --" />
                    <c:forEach items="${projectMembers}" var="member">
                        <form:option value="${member.userId}">${member.username}</form:option>
                    </c:forEach>
                </form:select>
                <form:errors path="assigneeId" cssClass="text-danger" />
            </div>

            <div class="col-md-3">
                <form:label path="dueDate" class="form-label">Due Date</form:label>
                <form:input path="dueDate" type="date" class="form-control" value="${workPackage.dueDate}" />
            </div>

            <div class="col-md-3">
                <form:label path="estimatedHours" class="form-label">Estimated Hours *</form:label>
                <form:input path="estimatedHours" type="number" step="0.50" min="0.50" class="form-control"
                    placeholder="0.00" />
                <form:errors path="estimatedHours" cssClass="text-danger" />
            </div>

            <div class="col-12 d-flex flex-wrap gap-2 pt-2">
                <button type="submit" class="btn btn-primary">
                    <i class="bi bi-check-lg me-1"></i>${workPackage.id == null ? 'Create Work Package' : 'Save Changes'}
                </button>
                <a href="${pageContext.request.contextPath}/work-packages/project/${workPackage.projectId}"
                    class="btn btn-outline-primary">
                    <i class="bi bi-x-lg me-1"></i>Cancel
                </a>
            </div>
        </div>
    </form:form>
</div>

<%@ include file="../layout/footer.jsp" %>
