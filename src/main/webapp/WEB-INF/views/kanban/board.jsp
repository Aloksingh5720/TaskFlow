<%@ include file="../layout/header.jsp" %>
    <%@ taglib prefix="c" uri="jakarta.tags.core" %>
        <%@ taglib prefix="fmt" uri="jakarta.tags.fmt" %>
            <%@ taglib prefix="fn" uri="jakarta.tags.functions" %>

            <style>
                .kanban-column-body.drag-over {
                    outline: 2px dashed var(--md-primary);
                    outline-offset: 6px;
                    border-radius: 1rem;
                    background: color-mix(in srgb, var(--md-primary) 6%, transparent);
                }

                .kanban-card.is-dragging {
                    opacity: 0.45;
                    transform: rotate(1.5deg);
                    cursor: grabbing;
                }

                .kanban-card[draggable="true"] {
                    cursor: grab;
                }
            </style>

            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4 page-header">
                <div>
                    <c:choose>
                        <c:when test="${not empty project}">
                            <h2 class="mb-1">Trace Board - ${project.name}</h2>
                            <p class="text-muted mb-0">Track work packages by status for this project.</p>
                        </c:when>
                        <c:otherwise>
                            <h2 class="mb-1">Trace Board</h2>
                            <p class="text-muted mb-0">Track work packages by status.</p>
                        </c:otherwise>
                    </c:choose>
                </div>
                <div class="d-flex flex-wrap gap-2">
                    <c:if test="${not empty project and showAdminOption}">
                        <button type="button" class="btn btn-primary btn-sm"
                            data-bs-toggle="modal" data-bs-target="#createWorkPackageModal">
                            <i class="bi bi-plus-lg me-1"></i>New Work Package
                        </button>
                    </c:if>
                    <c:if test="${not empty project}">
                        <a href="${pageContext.request.contextPath}/work-packages/project/${project.id}"
                            class="btn btn-secondary btn-sm">
                            <i class="bi bi-list-task me-1"></i>List View
                        </a>
                        <a href="${pageContext.request.contextPath}/projects/${project.id}" class="btn btn-secondary btn-sm">
                            <i class="bi bi-arrow-left me-1"></i>Back to Project
                        </a>
                    </c:if>
                </div>
            </div>

            <c:choose>
                <c:when test="${empty statuses}">
                    <div class="section-card text-center py-5">
                        <i class="bi bi-columns-gap" style="font-size:2.25rem;opacity:0.45"></i>
                        <div class="mt-2">No statuses configured yet.</div>
                    </div>
                </c:when>
                <c:otherwise>
                    <div class="kanban-board-wrap">
                        <div class="kanban-board">
                            <c:forEach items="${statuses}" var="status">
                                <c:set var="cards" value="${workPackagesByStatus[status]}" />
                                <section class="kanban-column">
                                    <header class="kanban-column-header">
                                        <div class="kanban-column-title">${fn:replace(status, '_', ' ')}</div>
                                        <span class="kanban-column-count">${cards != null ? cards.size() : 0}</span>
                                    </header>

                                    <div class="kanban-column-body" data-status="${status.name()}">
                                        <c:choose>
                                            <c:when test="${empty cards}">
                                                <div class="kanban-empty">
                                                    <i class="bi bi-inbox"></i>
                                                    <span>No work packages</span>
                                                </div>
                                            </c:when>
                                            <c:otherwise>
                                                <c:forEach items="${cards}" var="wp">
                                                    <article class="kanban-card"
                                                        draggable="${canDragWorkPackages}"
                                                        data-id="${wp.id}"
                                                        data-status="${wp.workPackageStatus.name()}"
                                                        data-type="${wp.workPackageType.name()}"
                                                        data-priority="${wp.workPackagePriority.name()}">
                                                        <div class="kanban-card-top">
                                                            <a class="kanban-card-title"
                                                                href="${pageContext.request.contextPath}/work-packages/${wp.id}">
                                                                ${wp.subject}
                                                            </a>
                                                            <span class="kanban-card-id">#${wp.id}</span>
                                                        </div>

                                                        <div class="kanban-card-meta">
                                                            <span class="chip chip-surface">${fn:replace(wp.workPackageType.name(), '_', ' ')}</span>
                                                            <c:if test="${not empty wp.workPackagePriority}">
                                                                <span class="chip chip-warning">${fn:replace(wp.workPackagePriority.name(), '_', ' ')}</span>
                                                            </c:if>
                                                        </div>

                                                        <div class="kanban-card-info">
                                                            <span>
                                                                <i class="bi bi-person"></i>
                                                                ${wp.assigneeName != null ? wp.assigneeName : 'Unassigned'}
                                                            </span>
                                                            <span>
                                                                <i class="bi bi-calendar-event"></i>
                                                                <c:choose>
                                                                    <c:when test="${wp.dueDate != null}">
                                                                        ${wp.dueDate}
                                                                    </c:when>
                                                                    <c:otherwise>No due date</c:otherwise>
                                                                </c:choose>
                                                            </span>
                                                        </div>
                                                    </article>
                                                </c:forEach>
                                            </c:otherwise>
                                        </c:choose>
                                    </div>
                                </section>
                            </c:forEach>
                        </div>
                    </div>
                </c:otherwise>
            </c:choose>

            <c:if test="${not empty project and showAdminOption}">
                <%@ include file="../workpackage/_create-modal.jsp" %>
            </c:if>

            <script>
                (() => {
                    const board = document.querySelector('.kanban-board');
                    if (!board) {
                        return;
                    }

                    const csrfToken = '${_csrf.token}';
                    const csrfParameter = '${_csrf.parameterName}';
                    const contextPath = '${pageContext.request.contextPath}';
                    const origin = window.location.origin;
                    let draggedCard = null;

                    const canDragWorkPackages = ${canDragWorkPackages ? 'true' : 'false'};
                    if (!canDragWorkPackages) {
                        return;
                    }

                    const cards = board.querySelectorAll('.kanban-card[draggable="true"]');
                    const columns = board.querySelectorAll('.kanban-column-body[data-status]');

                    cards.forEach((card) => {
                        card.addEventListener('dragstart', (event) => {
                            draggedCard = card;
                            card.classList.add('is-dragging');
                            event.dataTransfer.effectAllowed = 'move';
                            event.dataTransfer.setData('text/plain', card.dataset.id);
                        });

                        card.addEventListener('dragend', () => {
                            card.classList.remove('is-dragging');
                            columns.forEach((column) => column.classList.remove('drag-over'));
                            draggedCard = null;
                        });
                    });

                    columns.forEach((column) => {
                        column.addEventListener('dragover', (event) => {
                            event.preventDefault();
                            column.classList.add('drag-over');
                            event.dataTransfer.dropEffect = 'move';
                        });

                        column.addEventListener('dragleave', () => {
                            column.classList.remove('drag-over');
                        });

                        column.addEventListener('drop', async (event) => {
                            event.preventDefault();
                            column.classList.remove('drag-over');

                            if (!draggedCard) {
                                return;
                            }

                            const nextStatus = column.dataset.status;
                            const currentStatus = draggedCard.dataset.status;
                            const workPackageId = draggedCard.dataset.id;
                            if (!nextStatus || nextStatus === currentStatus) {
                                return;
                            }

                            if (!workPackageId) {
                                window.alert('Unable to update work package status: missing work package id.');
                                return;
                            }

                            const params = new URLSearchParams();
                            params.append('status', nextStatus);
                            if (csrfParameter) {
                                params.append(csrfParameter, csrfToken);
                            }

                            const basePath = contextPath && contextPath !== '/' ? contextPath.replace(/\/+$/, '') : '';
                            const requestPath = (basePath + '/work-packages/' + workPackageId + '/status')
                                .replace(/\/{2,}/g, '/');
                            const requestUrl = new URL(requestPath, origin).toString();

                            try {
                                const response = await fetch(
                                    requestUrl,
                                    {
                                        method: 'POST',
                                        headers: {
                                            'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8'
                                        },
                                        body: params.toString(),
                                        credentials: 'same-origin'
                                    }
                                );

                                if (!response.ok) {
                                    throw new Error(`Update failed with status ${response.status}`);
                                }

                                window.location.reload();
                            } catch (error) {
                                console.error(error);
                                window.alert('Unable to update work package status. Check permissions or server logs.');
                            }
                        });
                    });
                })();
            </script>

            <%@ include file="../layout/footer.jsp" %>
