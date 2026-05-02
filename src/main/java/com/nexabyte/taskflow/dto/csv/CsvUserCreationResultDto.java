package com.nexabyte.taskflow.dto.csv;

import java.util.List;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CsvUserCreationResultDto {

    private int totalRecords;
    private int successCount;
    private int failureCount;
    private List<String> successMessages;
    private List<String> errorMessages;
}
