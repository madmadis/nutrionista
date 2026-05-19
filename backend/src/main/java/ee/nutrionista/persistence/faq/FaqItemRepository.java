package ee.nutrionista.persistence.faq;

import org.springframework.data.jpa.repository.JpaRepository;

public interface FaqItemRepository extends JpaRepository<FaqItem, Integer> {
}
