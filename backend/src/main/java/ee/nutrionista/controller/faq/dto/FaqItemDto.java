package ee.nutrionista.controller.faq.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class FaqItemDto {
    private Integer faqItemId;
    private String section;
    private String question;
    private String answer;
}
