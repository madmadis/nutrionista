package ee.nutrionista.persistence.blog;

import ee.nutrionista.controller.blog.dto.BlogArticleDto;
import org.mapstruct.Mapper;
import org.mapstruct.Mapping;

import java.util.List;

@Mapper(componentModel = "spring")
public interface BlogArticleMapper {

    @Mapping(source = "id", target = "blogArticleId")
    @Mapping(source = "title", target = "title")
    @Mapping(source = "summary", target = "summary")
    @Mapping(source = "content", target = "content")
    @Mapping(source = "imageUrl", target = "imageUrl")
    BlogArticleDto toBlogArticleDto(BlogArticle blogArticle);

    List<BlogArticleDto> toBlogArticleDtos(List<BlogArticle> blogArticles);
}