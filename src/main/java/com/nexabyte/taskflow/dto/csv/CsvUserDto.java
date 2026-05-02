package com.nexabyte.taskflow.dto.csv;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CsvUserDto {

    private String username;
    private String email;
    private String password;
    private String name;
    private boolean enabled;
    private Long globalRoleId;
}
