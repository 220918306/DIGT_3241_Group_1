package org.springframework.samples.petclinic.genai.web;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.reactive.WebFluxTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.web.reactive.server.WebTestClient;

@WebFluxTest(GenAiController.class)
@ActiveProfiles("test")
class GenAiControllerTest {

	@Autowired
	private WebTestClient webTestClient;

	@Test
	void shouldReturnGenAiServiceStatus() {
		webTestClient.get()
			.uri("/genai/status")
			.exchange()
			.expectStatus().isOk()
			.expectBody()
			.jsonPath("$.service").isEqualTo("genai-service")
			.jsonPath("$.status").isEqualTo("UP")
			.jsonPath("$.description").isEqualTo("Spring PetClinic Generative AI microservice");
	}

}
