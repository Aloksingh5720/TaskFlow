<%@ include file="../layout/header.jsp" %>
<%@ taglib prefix="c" uri="jakarta.tags.core" %>

<style>
    .section-card {
        overflow: visible;
    }

    #projectGanttContainer {
        padding-right: 1.25rem !important;
        padding-bottom: 0 !important;
        scrollbar-gutter: stable both-edges;
        overflow-x: auto !important;
        overflow-y: visible !important;
        position: relative;
    }

    .project-gantt-inner {
        display: inline-block;
        min-width: 100%;
        padding-bottom: 2 rem;
    }

    #projectGantt {
        display: block;
        margin-bottom: 0;
    }

    #projectGantt .bar-wrapper,
    #projectGantt .handle-group,
    #projectGantt .arrow,
    #projectGantt .gantt-popup-wrapper {
        cursor: default !important;
    }

    #projectGantt .handle-group,
    #projectGantt .arrow {
        display: none !important;
    }

    .popup-wrapper,
    .gantt-container .popup-wrapper {
        z-index: 20 !important;
    }
</style>

<div class="d-flex align-items-center justify-content-between flex-wrap gap-3 mb-4 page-header">
    <div>
        <h2 class="mb-1">Gantt Chart - ${project.name}</h2>
        <p class="text-muted mb-0">Review work packages on a timeline with status-derived progress.</p>
    </div>
    <div class="d-flex flex-wrap gap-2">
        <a href="${pageContext.request.contextPath}/work-packages/project/${project.id}" class="btn btn-secondary btn-sm">
            <i class="bi bi-list-task me-1"></i>List View
        </a>
        <a href="${pageContext.request.contextPath}/projects/${project.id}" class="btn btn-secondary btn-sm">
            <i class="bi bi-arrow-left me-1"></i>Back to Project
        </a>
    </div>
</div>

<div class="section-card">
    <div class="d-flex align-items-center justify-content-between mb-3 flex-wrap gap-2">
        <span class="section-label">
            <i class="bi bi-calendar3-range me-1"></i>
            Work Package Timeline
        </span>
    </div>
    <div id="projectGanttEmptyState" class="py-4 text-center" style="display: none; color: var(--md-on-surface-variant)">
        No work packages with usable timeline dates yet.
    </div>
    <div id="projectGanttContainer" style="display: none; overflow-x: auto;">
        <div class="project-gantt-inner">
            <svg id="projectGantt" style="min-width: 960px; width: 100%"></svg>
        </div>
    </div>
</div>

<link rel="stylesheet" href="${pageContext.request.contextPath}/css/frappe-gantt.css" />
<script src="${pageContext.request.contextPath}/js/frappe-gantt.umd.js"></script>
<script>
    (function () {
        var ganttRoot = document.getElementById('projectGantt');
        var ganttContainer = document.getElementById('projectGanttContainer');
        var emptyState = document.getElementById('projectGanttEmptyState');
        if (!ganttRoot || !window.Gantt) return;

        function escapeHtml(value) {
            return String(value || '')
                .replace(/&/g, '&amp;')
                .replace(/</g, '&lt;')
                .replace(/>/g, '&gt;')
                .replace(/"/g, '&quot;')
                .replace(/'/g, '&#39;');
        }

        function getCurrentMonthStart() {
            var today = new Date();
            return new Date(today.getFullYear(), today.getMonth(), 1);
        }

        fetch('${pageContext.request.contextPath}/projects/${project.id}/gantt-tasks', {
            headers: {
                'Accept': 'application/json'
            }
        })
            .then(function(response) {
                if (!response.ok) {
                    throw new Error('Failed to load project timeline.');
                }
                return response.json();
            })
            .then(function(tasks) {
                if (!tasks.length) {
                    emptyState.style.display = 'block';
                    return;
                }

                ganttContainer.style.display = 'block';

                new Gantt('#projectGantt', tasks, {
                    view_mode: 'Day',
                    language: 'en',
                    scroll_to: getCurrentMonthStart(),
                    readonly: true,
                    readonly_dates: true,
                    readonly_progress: true,
                    popup_on: 'hover',
                    custom_popup_html: function(task) {
                        return [
                            '<div class="details-container" style="padding: 0.85rem 1rem; min-width: 220px;">',
                            '<h6 style="margin: 0 0 0.5rem 0;">' + escapeHtml(task.name) + '</h6>',
                            '<div style="font-size: 0.85rem; color: #5f6368;">Status: ' + escapeHtml(task.status.replace(/_/g, ' ')) + '</div>',
                            '<div style="font-size: 0.85rem; color: #5f6368;">Progress: ' + escapeHtml(task.progress) + '%</div>',
                            '<div style="font-size: 0.85rem; color: #5f6368;">Start: ' + escapeHtml(task.start) + '</div>',
                            '<div style="font-size: 0.85rem; color: #5f6368;">End: ' + escapeHtml(task.end) + '</div>',
                            '<div style="font-size: 0.85rem; color: #5f6368;">Assignee: ' + escapeHtml(task.assignee || 'Unassigned') + '</div>',
                            '</div>'
                        ].join('');
                    }
                });

            })
            .catch(function(error) {
                emptyState.style.display = 'block';
                console.error(error);
            });
    })();
</script>
<%@ include file="../layout/footer.jsp" %>
