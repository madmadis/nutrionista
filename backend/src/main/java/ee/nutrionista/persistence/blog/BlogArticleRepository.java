package ee.nutrionista.persistence.blog;

import org.springframework.data.jpa.repository.JpaRepository;

public interface BlogArticleRepository extends JpaRepository<BlogArticle, Integer> {
}
