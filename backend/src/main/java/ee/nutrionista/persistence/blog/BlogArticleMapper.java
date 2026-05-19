package ee.nutrionista.persistence.blog;

import ee.nutrionista.controller.blog.dto.BlogArticleDto;
import org.mapstruct.Mapper;

@Mapper(componentModel = "spring")
public interface BlogArticleMapper {
    BlogArticleDto toDto(BlogArticle blogArticle);
}
