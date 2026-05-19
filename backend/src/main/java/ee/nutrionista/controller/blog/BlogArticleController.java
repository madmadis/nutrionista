package ee.nutrionista.controller.blog;

import ee.nutrionista.controller.blog.dto.BlogArticleDto;
import ee.nutrionista.service.BlogArticleService;
import io.swagger.v3.oas.annotations.Operation;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
public class BlogArticleController {
    private final BlogArticleService blogArticleService;

    @GetMapping("/blog")
    @Operation(summary = "Blogipostitused")
    public List<BlogArticleDto> findAllBlogArticles() {
        return blogArticleService.findAllBlogArticles();
    }
}
