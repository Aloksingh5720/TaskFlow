package com.nexabyte.taskflow.dto.gantt;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class GanttTaskDto {

    private String id;
    private String name;
    private String start;
    private String end;
    private int progress;
    private String status;
    private String assignee;
}
