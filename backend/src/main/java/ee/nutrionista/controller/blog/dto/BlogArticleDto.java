package ee.nutrionista.controller.blog.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor

public class BlogArticleDto {
    private Integer id;
    private String title;
    private String summary;
    private String content;
    private String imageUrl;
}
