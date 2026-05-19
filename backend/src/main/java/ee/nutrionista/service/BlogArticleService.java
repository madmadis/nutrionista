package ee.nutrionista.service;

import ee.nutrionista.controller.blog.dto.BlogArticleDto;
import ee.nutrionista.persistence.blog.BlogArticleMapper;
import ee.nutrionista.persistence.blog.BlogArticleRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class BlogArticleService {

    private final BlogArticleRepository blogArticleRepository;
    private final BlogArticleMapper blogArticleMapper;

    public List<BlogArticleDto> all() {
        return blogArticleRepository.findAll()
                .stream()
                .map(blogArticleMapper::toDto)
                .toList();
    }
}
